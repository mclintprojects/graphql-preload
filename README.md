# GraphQL::Preload

[![Gem Version](https://badge.fury.io/rb/graphql-preload.svg)](https://rubygems.org/gems/graphql-preload)

Provides a DSL for the [`graphql` gem](https://github.com/rmosolgo/graphql-ruby) that allows ActiveRecord associations to be preloaded in field definitions. Based on a [gist](https://gist.github.com/theorygeek/a1a59a2bf9c59e4b3706ac68d12c8434) by @theorygeek.

This fork works with Ruby on Rails 6.0 and GraphQL-Ruby 1.10 (but not in interpreter mode yet).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-preload'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql-preload

## Usage

Add `GraphQL::Batch` to your schema

```ruby
class PreloadSchema < GraphQL::Schema
  use GraphQL::Batch

  query QueryType
end
```

Call `preload` when defining your field:

```ruby
class PostType < GraphQL::Schema::Object
  # This runs Post.includes(:comments) but only if comments are requested
  field :comments,  [CommentType], null: false, preload: :comments

  # Block syntax is supported too
  field :comments,  [CommentType], null: false
    preload :comments

    # Post.includes(:comments, :authors)
    preload [:comments, :authors]

    # Post.includes(:comments, authors: [:followers, :posts])
    preload [:comments, { authors: [:followers, :posts] }]
  end
end
```

### `preload_scope`
Starting with Rails 4.1, you can scope your preloaded records by passing a valid scope to [`ActiveRecord::Associations::Preloader`](https://apidock.com/rails/v4.1.8/ActiveRecord/Associations/Preloader/preload). Scoping can improve performance by reducing the number of models to be instantiated and can help with certain business goals (e.g., only returning records that have not been soft deleted).

This functionality is surfaced through the `preload_scope` option:

```ruby
class UserType < GraphQL::Schema::Object
  field :posts, [PostType], null: false,
                            preload: :posts,
                            preload_scope: ->(*) { Post.order(rating: :desc) }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ConsultingMD/graphql-preload.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
