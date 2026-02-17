# Riff Gem — Codebase Audit

Date: 2026-02-08

---

## CRITICAL — Will Crash at Runtime

### 1. `.joni()` instead of `.join()`

- `lib/riff/request/response_body_validator.rb:63` and `:67`
- Typo that throws `NoMethodError`. These paths are either never hit (meaning the validator is dead code) or they're a ticking bomb.

### 2. `raise_action_not_found!` is never defined

- `lib/riff/request/validate/action.rb:33` — calls a method that doesn't exist anywhere in the class hierarchy. Should be `raise(Exceptions::ActionNotFound, ...)`.

### 3. `::Util::Array.smart_join` doesn't exist in the gem

- `lib/riff/hash_validator.rb:50` — references an external utility module that isn't bundled. Will `NameError` on any hash validation failure.

### 4. `@req` is never set in `RemoteIp::GetIp`

- `lib/riff/request/remote_ip.rb:58-59` — copied from Rails but not adapted. If an IP spoofing attack is detected, the error handler itself crashes with `NoMethodError` on nil.

### 5. `SECRET_KEY_BASE` can be nil

- `lib/riff/auth/default_method/token/message_signer.rb:22` — `ENV.fetch("SECRET_KEY_BASE", nil)` silently passes `nil` to `MessageVerifier.new`. If the env var is missing, all tokens are signed with a nil key. Zero validation that it's present.

### 6. `HandleError` crashes when no icon is configured

- `lib/riff/handle_error.rb:50` — if `@error.icon` is nil and `Conf.default_error_icon` is nil, the error handler raises `RuntimeError` from inside itself. The error handler has its own unhandled error.

---

## CRITICAL — Architecture / Portability

### 7. Hardcoded `::SellerToken` — the gem is not reusable

- `lib/riff/auth/default_method/token/util.rb:11`, `create_token.rb:35`, `token_validator.rb:41`
- Three direct references to an application-specific model. This gem cannot be used outside the app. Should be `Conf.token_class`.

### 8. Hardcoded `::Company` in Swagger

- `lib/riff/swagger/main.rb:61` — `Company.new(nome_fantasia: "Company")` — a Portuguese field name inside a framework gem.

### 9. `Memo` module is used but never defined

- `lib/riff/swagger/verb.rb:4` and `token_validator.rb:8` — `extend Memo`. This module comes from somewhere outside the gem. Not in any declared dependency. Silent dependency on the host app.

### 10. Zero runtime dependencies declared in gemspec

- `riff.gemspec:35-36` — The gem uses `sequel`, `dry-validation`, `activesupport`, `i18n`, `oj`, `dry-swagger`. None are declared. `bundle install` on a fresh project would fail immediately.

---

## SECURITY

### 11. No max pagination limit

- `lib/riff/actions/helpers/pagination.rb:35-37` — `_limit` param accepts any integer. `?_limit=999999999` fetches the entire table. Trivial DoS and data exfiltration vector.
- Fix: add a `max_per_page` config to `Conf` and clamp `_limit`.

### 12. `YAML.load` without `safe_load`

- `lib/riff/swagger/main.rb:26` — allows arbitrary Ruby object deserialization.
- Fix: replace with `YAML.safe_load` or `YAML.load(..., permitted_classes: [...])`.

### 13. Token purpose decided by URL substring

- `lib/riff/auth/default_method/request_auth.rb:17` — `@context.url.include?("refresh_token")` — if any URL happens to contain the string `refresh_token`, auth logic switches from access token to refresh token validation. Fragile and exploitable.
- Fix: use explicit route matching or a request attribute, not string inclusion.

### 14. 180-day refresh token lifetime

- `lib/riff/auth/default_method/token/create_tokens.rb:9` — a stolen refresh token works for 6 months with no rotation of the JWT itself.
- Fix: make configurable via `Conf`, shorten default, consider refresh token rotation.

### 15. `false` values stripped from responses

- `lib/riff/request/result.rb:37` — `body.delete(k) if body[k].blank?` — ActiveSupport's `blank?` returns `true` for `false`. Any boolean `false` field silently disappears from API responses.
- Fix: use `body[k].nil?` instead of `body[k].blank?`.

---

## TESTING

### 16. The gem's own spec deliberately fails

- `spec/riff_spec.rb` — `expect(false).to(eq(true))`. Scaffolding placeholder from `bundle gem` that was never replaced.

### 17. Zero unit tests for 64 production files

Every single class in `lib/riff/` has zero dedicated unit tests. All coverage is integration-only through `sample_app/spec/`. The full list of untested files:

**Core framework:** `conf.rb`, `settings.rb`, `enable.rb`, `authorize.rb`, `base_action.rb`, `util.rb`, `constants.rb`, `http_verbs.rb`, `exceptions.rb`, `handle_error.rb`, `validator.rb`, `dynamic_validator.rb`, `fallback_validator.rb`, `hash_validator.rb`, `validate.rb`, `request_log.rb`

**Request pipeline:** `request/action_processor.rb`, `request/session_processor.rb`, `request/chain.rb`, `request/context.rb`, `request/context/action.rb`, `request/context/model.rb`, `request/context/resource.rb`, `request/context/web_request.rb`, `request/validate.rb`, `request/validate/action.rb`, `request/validate/custom_method_id.rb`, `request/result.rb`, `request/set_response.rb`, `request/response_body.rb`, `request/response_body_validator.rb`, `request/remote_ip.rb`

**Request handlers:** `request_handlers/base.rb`, `request_handlers/auth.rb`, `request_handlers/authorization.rb`, `request_handlers/action.rb`, `request_handlers/check_params.rb`

**CRUD actions:** `actions/base.rb`, `actions/index.rb`, `actions/create.rb`, `actions/update.rb`, `actions/show.rb`, `actions/delete.rb`

**Action helpers:** `actions/helpers/record.rb`, `actions/helpers/attributes.rb`, `actions/helpers/pagination.rb`, `actions/helpers/order.rb`, `actions/helpers/save.rb`, `actions/helpers/result_builder.rb`, `actions/helpers/success_body.rb`, `actions/helpers/error_body.rb`, `actions/helpers/icon.rb`

**Auth system:** `auth/request_auth_method.rb`, `auth/signin_auth_method.rb`, `auth/default_method/signin_auth.rb`, `auth/default_method/request_auth.rb`, `auth/default_method/token/create_token.rb`, `auth/default_method/token/create_tokens.rb`, `auth/default_method/token/token_validator.rb`, `auth/default_method/token/message_signer.rb`, `auth/default_method/token/update_auth_token.rb`, `auth/default_method/token/invalidate_auth_token.rb`, `auth/default_method/token/util.rb`

**Session:** `session/open.rb`, `session/close.rb`, `session/refresh.rb`

**Swagger/OAS:** `swagger/main.rb`, `swagger/read.rb`, `swagger/verb.rb`

### 18. Auth checks never applied to CRUD endpoints

The `'authorization check'` shared example (tests missing/invalid/revoked tokens) is only used in session specs. No CRUD endpoint test ever verifies that unauthenticated requests are rejected.

### 19. All test users are admins

- `sample_app/spec/factories/users.rb` — `is_admin { true }`. Non-admin authorization paths are completely untested.

### 20. Commented-out tests hiding real gaps

- `post/delete_spec.rb:28-73` — invalid ID and cross-user delete tests are commented out.
- `throttling_spec.rb:64-88` — sign-up throttling test commented out.
- Company index/show/delete have zero specs at all.

### 21. Swagger/OAS module — zero tests

The entire `Riff::Swagger` namespace (3 files, ~300 lines) is untested.

### 22. Other test quality issues

- Session open/close specs mock token creation entirely — real token code paths are never exercised in those tests.
- `FactoryBot` `to_create(&:save)` silences validation failures (returns false instead of raising).
- Throttling test hits `/actions/messages` which doesn't exist in the sample app.
- `FactoryBot.use_parent_strategy = false` may cause unintended DB writes.

---

## DESIGN PROBLEMS

### 23. `Context` is a God Object

- `lib/riff/request/context.rb` — mixes in 4 modules (`WebRequest`, `Resource`, `Action`, `Model`), acts as request parser, router, model locator, user store, scope store, params store, and settings container. Everything depends on it. Untestable in isolation.

### 24. `Conf` is an unprotected global singleton

- No thread safety (bare `@ivar` writes in a multi-threaded server like Puma).
- No `reset!` for tests.
- No way to have two configurations.
- Lambda defaults like `logger: lambda { Logger.new(STDOUT) }` create a new Logger instance on every access.

### 25. `Riff.configure` is broken

- `lib/riff.rb:91-94` — calls `instance_eval(&block)` on the `Riff` module, but all setters live on `Conf`. The configure block doesn't do what it looks like it should.

### 26. `RemoteIp` pollutes the global namespace

- `lib/riff/request/remote_ip.rb:7` — defined as `class RemoteIp`, not `class Riff::Request::RemoteIp`. Will conflict with any other gem or app code defining `RemoteIp`.

### 27. Competing defaults for `per_page`

- `Conf.default_per_page` is 20 (`conf.rb:20`), `Constants::DEFAULT_PER_PAGE` is 10 (`constants.rb:7`). The constant is dead because Conf always wins.

### 28. Two base action classes with no documentation on which to use

- `lib/riff/base_action.rb` and `lib/riff/actions/base.rb` — both exist, both are used, no guidance on which is for what. (`BaseAction` appears to be for custom/session actions, `Actions::Base` for CRUD, but nothing says so.)

### 29. Error handling duplicated between processors

- `lib/riff/request/action_processor.rb:17-24` and `session_processor.rb:22-28` — nearly identical rescue/log/wrap logic. Only difference: `ActionProcessor` also sends to Sentry.

### 30. `methods` shadows `Object#methods`

- `lib/riff/request_handlers/auth.rb:40` — `def methods` returns auth method classes instead of Ruby method names. Will cause baffling debugging sessions.

### 31. Inconsistent error raising patterns

The codebase uses four different patterns to raise errors:
1. `raise(ExceptionClass, message)` — standard Ruby
2. `ExceptionClass.raise!(keyword_args)` — custom class method
3. `raise(ExceptionClass.create(args))` — custom factory method
4. `raise("must implement!")` — bare string (`request_auth_method.rb:12,16`, `signin_auth_method.rb:10,14`)

Pattern 4 raises `RuntimeError` instead of `NotImplementedError`. Cannot rescue abstract-method violations uniformly.

### 32. Swallowed exception in `MessageSigner.decode`

- `lib/riff/auth/default_method/token/message_signer.rb:14-18` — `InvalidSignature` is rescued and silently returns `nil`. No logging. A tampered token is indistinguishable from an expired token.

---

## CODE QUALITY

### 33. Typos baked into data structures

- `inpersonator_id` (should be `impersonator`) — `create_token.rb:25,27`, `token_validator.rb:17` — persisted in tokens. Fixing it later breaks existing tokens.
- `ACCCESS_TOKEN_EXPIRES_IN` (triple C) — `create_tokens.rb:8`
- `resfull` (should be `restful`) — `riff.gemspec:11`

### 34. "brush" naming is opaque

- `conf.rb:67`, `result.rb:34`, `response_body.rb:37`, `swagger/verb.rb:137` — nobody knows what "brush" means. Used for transforms/normalization across 4 files.

### 35. Debug `puts` throughout production code

- `session_processor.rb` — 6 active `puts` behind `DEBUG = false`
- `session/close.rb` — 6 commented-out `puts`
- `riff.rb:102`, `show.rb:9`, `create_token.rb:16`, `message_signer.rb:17` — more commented-out debug prints

### 36. 7 TODOs left behind

| File | Line | Comment |
|------|------|---------|
| `hash_validator.rb` | 4 | `# TODO convert all uses of this class to a dry-validation-contract` |
| `hash_validator.rb` | 25 | `# TODO: handle blank? of booleans` |
| `hash_validator.rb` | 26 | `# TODO give option to deny blank values` |
| `response_body_validator.rb` | 5 | `# TODO convert to dry validation contract` |
| `context/action.rb` | 18 | `# TODO: check need if camelize or classify if` |
| `context.rb` | 3 | `# TODO: implement lazy properties` |
| `context/web_request.rb` | 31 | `# TODO validate` |

### 37. 4 files missing `frozen_string_literal` pragma

- `request/response_body.rb`
- `swagger/verb.rb`
- `auth/signin_auth_method.rb`
- `auth/default_method/signin_auth.rb`

### 38. Dead code

- `ResponseBody` class (`request/response_body.rb`) — never required, never referenced
- `model_less_resources` config (`conf.rb:24`) — set but never read
- `Riff.config` accessor (`riff.rb:89`) — set but everything uses `Conf` directly
- `Swagger::Read#sort` (`swagger/read.rb:25-29`) — iterates but never assigns; returns unchanged data
- `@use_fallback` in `validate.rb` — assigned in initialize, never read
- Commented-out `id?` method in `util.rb:31-33`

### 39. Code duplication

- `success?` — duplicated in `result.rb` and `response_body.rb`
- `response_body` assembly — duplicated in `create.rb` and `update.rb`
- `info_log` — duplicated in `request_handlers/auth.rb` and `session/open.rb`
- `raise_auth_error!` — duplicated in `request_auth_method.rb` and `signin_auth_method.rb`
- `after(rec)` no-op hook — duplicated in `helpers/save.rb` and `create.rb`
- Error handling — duplicated between `action_processor.rb` and `session_processor.rb`

### 40. Hardcoded magic values

| Value | Location | Issue |
|-------|----------|-------|
| `60` (access token TTL in seconds) | `create_tokens.rb:8` | Extremely aggressive, not configurable |
| `3600 * 24 * 30 * 6` (refresh TTL) | `create_tokens.rb:9` | Not configurable |
| `SecureRandom.hex(40)` | `token/util.rb:10` | Magic number |
| `"/v1"` path prefix | `swagger/verb.rb:27` | Hardcoded API version |
| `"SHA512"` digest | `message_signer.rb:22` | Hardcoded |
| `"asd@asd.com"`, `"123456"` | `swagger/main.rb:65-67` | Hardcoded test credentials |
| 21-element field name array | `session/open.rb:6-27` | Tries to cover every possible column name convention |
| `Sentry.capture_exception` | `action_processor.rb:29` | Direct Sentry reference, should be a configurable error reporter |
| `ENV['RACK_ENV'] == 'production'` | `action_processor.rb:29`, `handle_error.rb:63` | Should use a configurable flag |

### 41. Gemspec issues

- `allowed_push_host` URL has invalid path: `"https://rubygems.org/riff"` (`riff.gemspec:17`)
- `changelog_uri` points to non-standard path (`riff.gemspec:21`)
- `required_ruby_version >= 2.6.0` but project uses Ruby 3.0.3 (`riff.gemspec:15`)
- No development dependencies declared for rspec or rubocop

### 42. `OpenStruct` usage (deprecated in Ruby 3.4+)

- `lib/riff/request/context.rb:56` — `OpenStruct.new` for `custom`
- `lib/riff/swagger/main.rb:56,72` — `OpenStruct.new` for fake context
- Should use `Struct` or a plain object.

### 43. Unused rescue variables

- `lib/riff/actions/create.rb:19` — `rescue Sequel::ValidationFailed => e` — `e` is never used
- `lib/riff/actions/update.rb:16` — same

### 44. Comment typos

- `actions/helpers/attributes.rb:22` — `wans't`, `comparation`, `differente`
- `actions/helpers/attributes.rb:24` — same line
- `user/delete_spec.rb` — `returs` (should be `returns`)

---

## IMPLEMENTATION PRIORITY

### Do Now (runtime crashes + security)
- [ ] Fix `.joni()` typo (#1)
- [ ] Fix `raise_action_not_found!` (#2)
- [ ] Fix `::Util::Array.smart_join` (#3)
- [ ] Fix `@req` in RemoteIp (#4)
- [ ] Validate `SECRET_KEY_BASE` on boot (#5)
- [ ] Fix HandleError nil icon crash (#6)
- [ ] Add max pagination limit (#11)
- [ ] Replace `YAML.load` with `YAML.safe_load` (#12)
- [ ] Fix `false` stripping from responses (#15)

### Do This Sprint (portability + correctness)
- [ ] Extract `::SellerToken` into `Conf.token_class` (#7)
- [ ] Remove hardcoded `::Company` from Swagger (#8)
- [ ] Define or require `Memo` module (#9)
- [ ] Declare runtime dependencies in gemspec (#10)
- [ ] Fix token purpose URL substring check (#13)
- [ ] Make token expiry configurable (#14)
- [ ] Fix or remove the broken `Riff.configure` (#25)
- [ ] Fix `methods` shadowing `Object#methods` (#30)

### Do Next Sprint (testing + design)
- [ ] Remove/replace the failing placeholder spec (#16)
- [ ] Add auth shared examples to all CRUD specs (#18)
- [ ] Add non-admin user factory trait and test denials (#19)
- [ ] Uncomment or properly remove commented-out tests (#20)
- [ ] Namespace `RemoteIp` under `Riff::Request` (#26)
- [ ] Extract common error handling from processors (#29)
- [ ] Standardize error raising pattern (#31)
- [ ] Add unit tests for core classes: `Conf`, `Context`, `HandleError`, `Pagination` (#17)

### Ongoing Cleanup
- [ ] Delete dead code (#38)
- [ ] Remove debug `puts` statements (#35)
- [ ] Fix typos: `inpersonator`, `ACCCESS`, `resfull` (#33)
- [ ] Rename `brush` to something meaningful (#34)
- [ ] Resolve or remove TODOs (#36)
- [ ] Add missing `frozen_string_literal` pragmas (#37)
- [ ] Extract duplicated code (#39)
- [ ] Replace `OpenStruct` with `Struct` (#42)
- [ ] Fix gemspec metadata (#41)
- [ ] Replace magic values with config (#40)
