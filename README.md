# Homerun

Sometimes you need to execute sequence of commands,
depends on execution result you want to do some redirection in execution,
even retry execution of some part of sequence.
"homerun" gem is exactly what you want.

```ruby
class A < Homerun::Instruction
    step ->(ctx) { ctx[:greetings] += " hello" }
    step ->(ctx) { ctx[:greetings] += " my"; false }, failure: :end
    step ->(ctx) { ctx[:greetings] += " dear" }
    step ->(ctx) { ctx[:greetings] += " friend" }, name: :end
end

A.call(greetings: "Oh,")

=> "Oh, hello my friend"
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'homerun'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install homerun

## Usage

### plain execution of sequence
```ruby
  class A < Homerun::Instruction
    step ->(ctx) { ctx[:var] += 1  }
    step ->(ctx) { ctx[:var] += 1  }
    step ->(ctx) { ctx[:var] += 1  }
  end

  A.call(var: 0)
  => { var: 3, _pass: true }
```

### false step catch & redirection to another step
```ruby
  class B < Homerun::Instruction
    step ->(ctx) { false  }, failure: :recover
    step ->(ctx) { ctx[:var] += 3  }
    step ->(ctx) { ctx[:var] += 1  }, name: :recover
  end

  B.call(var: 0)
  => { var: 1, _pass: true }
```

### true step catch & redirection to another step
```ruby
  class B < Homerun::Instruction
    step ->(ctx) { true  }, success: :recover
    step ->(ctx) { ctx[:var] += 3  }
    step ->(ctx) { ctx[:var] += 1  }, name: :recover
  end

  B.call(var: 0)
  => { var: 1, _pass: true }
```
### _pass as a result state (true/false)
```ruby
  class C < Homerun::Instruction
    step ->(ctx) { false  }
    step ->(ctx) { ctx[:var] += 3  }
    step ->(ctx) { ctx[:var] += 1}
  end

  C.call(var: 0)
  => { var: 0, _pass: false }

  class D < Homerun::Instruction
    step ->(ctx) { ctx[:var] += 1 }
    step ->(ctx) { ctx[:var] += 1 }
    step ->(ctx) { false }
  end

  D.call(var: 0)
  => { var: 2, _pass: false }
```

### block execution on _pass == true
```ruby
  class C < Homerun::Instruction
    step ->(ctx) { ctx[:var] += 1 }
    step ->(ctx) { ctx[:var] += 1 }
  end

  C.call(var: 0) do |ctx|
    ctx[:var] += 1
  end

  => { var: 3, _pass: true }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/homerun. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Homerun project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/homerun/blob/master/CODE_OF_CONDUCT.md).
