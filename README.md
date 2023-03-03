# Riff

Riff is a ruby gem that permits you to quickly build a Restful API in ruby projects that is using [Roda](https://github.com/jeremyevans/roda) and [Sequel ORM](https://github.com/jeremyevans/sequel).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "riff", :git => "git://github.com/tomlobato/riff.git"
```

And then execute:

```sh
bundle install
```
## Features

- Authentication (access_token/refresh_token)
- Authorization
- Parameters checking
- Default CRUD actions
- Custom actions (aka restful custom methods)

## Based on

- [Roda](https://github.com/jeremyevans/roda)
- [Sequel ORM](https://github.com/jeremyevans/sequel)
- [ActiveSupport](https://github.com/rails/rails/tree/main/activesupport)
- [dry-validation](https://github.com/dry-rb/dry-validation)
- [todo_api](https://github.com/MatUrbanski/todo_api) for the sample app
- [Oj](https://github.com/ohler55/oj)

## Usage

Instead create a roda app from zero, copying the [sample riff app](https://github.com/tomlobato/riff/tree/main/sample_app) is a quick way to have your project up and running.

But if you prefer to plug riff directly in you app...

1) In your app.rb file (where you have `class App < Roda ...`), add entries like this to direct your requests to Riff (see the [sample riff app](https://github.com/tomlobato/riff/tree/main/sample_app)).

```ruby
route do |r|
  r.post('session', String) do |action|
    Riff.handle_session(r, response, action)
  end
  r.on('actions') do
    Riff.handle_action(r, response)
  end
end
```

2) Create the riff customizations inside your app inside the constant path `Actions::<MY_MODEL>::*` for each model you want to deliver in your api (see examples in [sample_app/app/riff/actions](https://github.com/tomlobato/riff/tree/main/sample_app/app/riff/actions)).

3) Configure Riff minimally setting the user class `Riff::Conf.set(:user_class, User)`, so riff can handle authentication for you. See a example in [riff.rb](https://github.com/tomlobato/riff/tree/main/sample_app/system/boot/riff.rb)).

See also the [sample_app](https://github.com/tomlobato/riff/tree/main/sample_app) and its [specs](https://github.com/tomlobato/riff/tree/main/sample_app/spec) for help on using Riff.

## Running tests

The automated tests for riff rest inside the sample_app:

```sh
cd sample_app
mysqladim create my_app_test
# Then create .env.test based on .env.test.template
RACK_ENV=test bundle exec rake db:migrate
RACK_ENV=test bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tomlobato/riff. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tomlobato/riff/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Riff project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tomlobato/riff/blob/main/CODE_OF_CONDUCT.md).

## Acknowledgements

Big thanks to [Jeremy Evans](https://github.com/jeremyevans) for bring to us Roda and Sequel, not mentioning [rodauth](https://github.com/jeremyevans/rodauth) and tons of other great code.

Big thanks to [Mateusz Urbański](https://github.com/MatUrbanski) for bring to us the great project [todo_api](https://github.com/MatUrbanski/todo_api), used in riff as a seed for the sample app and its authentication logic for Riff authentication handler.
