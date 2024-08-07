# StoryTeller [![CircleCI](https://circleci.com/gh/ConvertKit/story_teller.svg?style=svg&circle-token=e0815a0e82f28c82e3f9a461cb28147d23916059)](https://circleci.com/gh/ConvertKit/story_teller)

It's just logs. If you want to know what your application is doing, StoryTeller helps understand what's happening in production. Using chapters and stories, you can build complex logs that will tell a story about what is going on in your production environment.

## Core Concepts

Essentially, StoryTeller logs are build around chapters and stories. Stories are conceptually similar to how `Rails.logger` would work. Chapters on the other hand, is a subtle, yet powerful structure that allows you to create context around your stories.

At the root of everything, we're building key/value logging. And maybe an example would make more sense.

```rb
class BooksController < ApplicationController
  def purchase
    @purchase = Purchase.create(@integration, params[:orders])
    if @purchase.errors
      StoryTeller.tell(
        errors: @purchase.errors,
        message: "Purchase could not be saved."
      )
    end
  end
  around_action only: :purchase do |_, action|
    StoryTeller.chapter(title: "Books::Purchase", subtitle: @integration) do
      action.call
    end
  end
end
```

Chapters is a way to set some logging context that will execute inside a block. In the example above, the chapter set the context of the book purchase. In the controller action, logs will be created without the need to set a context, because all stories that are executed inside a chapter will inherit all the key/value of all the chapters.

## Documentation

StoryTeller is built around three concepts: `StoryTeller::Book`, `StoryTeller::Chapter` and `StoryTeller::Story`. Together they are the building blocks to create a clear context around your logs.

### Book
A book is lazily created for each of the thread your ruby program runs. When a chapter or a story is created, it will gather information for the current Book and assign some context, like UUID to the logs.

### Chapter
Chapter is what is created when invoking `StoryTeller.chapter(title:, subtitle:, &block)`. The chapter is a context that is created for all the logs that are going to occur inside the block that is passed. If you have a controller action that instantiates an object which, in turn, does a lot of things that you'd like to log, you should call `StoryTeller.chapter(title:, subtitle:, &block)` and do all the processing inside the block.

This way, StoryTeller will be able to assign all the logs to a given resource and event. This, in turn will make it possible for you to search for all the logs that happened on event XYZ with resource ABC.


### Story
Stories are basically a supercharged version of `Rails.logger.info`. You can pass a hash to it and also use that hash to construct a message.

```rb
StoryTeller.tell(
  account_id: @account.id,
  status: @subscription.status,
  email: @subscriber.email_address
  message: "Found subscriber %{email} with an %{status} subscription."
)
```

All the keys that you pass to StoryTeller are going to be indexed and searchable by default. So, as a rule of thumb, you should always store values that you want to interpolate in a string as a seperate entry in the hash because you never know when you'll need to search for those fields.

Also, if you `tell` a story inside a chapter block, your story will inherit the `event` and the `identifier` from the chapter so those will be indexed and searchable too.

## Set a different level for a story

Levels are a way to specify what kind of story you are writing. Currently, there are 3 levels and you can compose a story to include any of them:

- StoryTeller::STORY_LEVEL
- StoryTeller::ANALYTIC_LEVEL
- StoryTeller::ERROR_LEVEL

By default, every story are set to `StoryTeller::STORY_LEVEL`, except for when an uncaught exception happens inside a chapter. These special story use the `StoryTeller::ERROR_LEVEL`.

Those levels are used in a bitwise field so it's possible to create a story that has any combination of levels.

`StoryTeller.level()` is the API to use to set a different level on a given story. Here's an example of how to write a story that contains both the STORY_LEVEL and the ANALYTIC_LEVEL:

```ruby
StoryTeller.level(StoryTeller::STORY_LEVEL, StoryTeller::ANALYTIC_LEVEL).tell(
  my_value: 100,
  status: "active",
  message: "This log will be set to both levels"
)
```

By having different levels, it means you can filter those logs and be able to pipe those to different storage, depending on the level set on them. This is useful for when a chapter is used and different logs are created to generate different type of information.

For instance, some might be there to make sure the app behaves properly, while other logs is an aggregation of what has happened so it can be graphed in an analytical tool.

## Exception handling

StoryTeller logs any exceptions that occur inside a chapter block. When an exception occurs, it will log it using an internal `StoryTeller.tell` invocation then *reraise the error* so any exception handling above the block can do its thing (bugsnag, or maybe recovering to show a 404, etc).

A `sev` fields mark the severity of a log. In normal logging event, that value will be set to `StoryTeller::Book::INFO_LEVEL`. However, when an exception bubbles to StoryTeller, the chapter will set the severity level of all stories to `StoryTeller::Book::ERROR_LEVEL`. It's often useful to filter by severity level so you can have an overview of all the logs that were involved for a given error.
