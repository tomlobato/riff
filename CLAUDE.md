# CLAUDE.md - Riff Gem

## Commands
- `bundle exec rake` - run default (spec + rubocop)
- `bundle exec rspec` - run tests
- `bundle exec rspec spec/path_spec.rb:LINE` - run single test
- `bundle exec rubocop` - lint
- Integration tests live in `sample_app/spec/`, not the gem's own `spec/`

## Architecture

Riff is a REST API framework built on Roda + Sequel.

### Entry Points (`lib/riff.rb`)
- `Riff.handle_action(request, response)` - regular resource requests
- `Riff.handle_session(request, response, type)` - session open/close/refresh

### Request Pipeline
Context → Validate → **Chain**(Auth → Authorization → CheckParams → Action) → SetResponse

### Convention-Based Resource Discovery
Resources are discovered by mapping URL paths to constants under `Conf.resources_base_module` (default: `Resources`):

```
/post/123 → Resources::Post::*
```

Expected structure:
```
resources/post/
├── settings.rb      # Resources::Post::Settings (optional, falls back to Riff::Settings)
├── authorizer.rb    # Resources::Post::Authorize (required)
├── enable.rb        # Resources::Post::Enable (optional, falls back to Riff::Enable)
├── actions/         # Resources::Post::Actions::Stats (custom actions)
│   └── stats.rb
└── validators/      # Resources::Post::Validators::Create
    ├── create.rb
    └── update.rb
```

### Built-in CRUD Actions (`lib/riff/actions/`)
Index, Create, Show, Update, Delete — used when no custom action exists for the HTTP method.

### Auth & Sessions
Token-based auth with access/refresh tokens. Auth chain: validate token → check authorization → proceed.

### Configuration (`Riff::Conf`)
Singleton with defaults for: `db`, `default_auth_user_class`, `resources_base_module`, `default_per_page` (20), `field_username`, pagination, etc.

### Exceptions (`lib/riff/exceptions.rb`)
Custom exceptions map to HTTP status codes:
- `Error401`: AuthFailure, InvalidCredentials
- `Error403`: AuthorizationFailure
- `Error404`: ResourceNotFound, ActionNotFound
- `Error422`: InvalidParameters, DbValidationError, InvalidPathNodes
- `Error428`: PreconditionFailed
- `Error500`: NotImplemented, InternalServerError, RescuedActionError

## Code Style
- `.rubocop.yml`: Ruby 2.6 target, 120 char lines, double quotes, `EnabledByDefault: true`
- Sample app is excluded from rubocop
