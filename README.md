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

## Usage

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

2) Create the customizations inside your app following the constant path `module Actions; module <MY_MODEL>...` (see examples in [sample_app/app/riff/actions](https://github.com/tomlobato/riff/tree/main/sample_app/app/riff/actions)).

3) Configure Riff minimally setting the user class `Riff::Conf.set(:user_class, User)`, so riff can handle authentication for you. See a example in [riff.rb](sample_app/system/boot/riff.rb)).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tomlobato/riff. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/tomlobato/riff/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Riff project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tomlobato/riff/blob/main/CODE_OF_CONDUCT.md).

## Acknowledgements

Big thanks for [Jeremy Evans](https://github.com/jeremyevans) for bring to us Roda and Sequel, not mentioning [rodauth](https://github.com/jeremyevans/rodauth) and tons of other great code.

Big thanks for [Mateusz Urbański](https://github.com/MatUrbanski) for bring to us the great project [todo_api](https://github.com/MatUrbanski/todo_api), used in riff as a seed for the sample app and its authentication logic for Riff authentication handler.
