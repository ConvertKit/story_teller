# StoryTeller

It's just logs. If you want to know what your application is doing, StoryTeller helps understand what's happening in production. Using chapters and stories, you can build complex logs that will tell a story about what is going on in your production environment.

## Core Concepts

Essentially, StoryTeller logs are build around chapters and stories. Stories are conceptually similar to how `Rails.logger` would work. Chapters on the other hand, is a subtle, yet powerful structure that allows you to create context around your stories.

At the root of everything, we're building key/value logging. And maybe an example would make more sense.

```
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
    StoryTeller.with(title: "Books::Purchase", subtitle: @integration) do
      action.call
    end
  end
end
```

Chapters is a way to set some logging context that will execute inside a block. In the example above, the chapter set the context of the book purchase. In the controller action, logs will be created without the need to set a context, because all stories that are executed inside a chapter will inherit all the key/value of all the chapters.

## Documentation

StoryTeller is built around three concepts: `StoryTeller::Book`, `StoryTeller::Chapter` and `StoryTeller::Story`.

### Book
A book is an object that is created lazily as soon as a call is made to `StoryTeller.tell` or `StoryTeller.chapter`. Even though these 2 are class methods, StoryTeller is thread safe because it always refers to a book for the current thread. If a thread doesn't have a book, it will create one.

Each book has its own `UUID` that is going to be used by all stories and chapters so you can filter logs by request/jobs. That is particularly useful when you see something weird in the log and you want to follow step by step all the logs for a request.

### Chapter
Chapter is what is created when invoking `StoryTeller.chapter(title:, subtitle:, &block)`. The chapter is a context that is created for all the logs that are going to occur inside the block that is passed. If you have a controller action that instantiates an object which, in turn, does a lot of things that you'd like to log, you should call `StoryTeller.chapter(title:, subtitle:, &block)` and do all the processing inside the block.

This way, StoryTeller will be able to assign all the logs to a given resource and event. This, in turn will make it possible for you to search for all the logs that happened on event XYZ with resource ABC.


### Story
Stories are basically a supercharged version of `Rails.logger.info`. You can pass a hash to it and also use that hash to construct a message.

```
StoryTeller.tell(
  account_id: @account.id,
  status: @subscription.status,
  email: @subscriber.email_address
  message: "Found subscriber %{email} with an %{status} subscription."
)
```

All the keys that you pass to StoryTeller are going to be indexed and searchable by default. So, as a rule of thumb, you should always store values that you want to interpolate in a string as a seperate entry in the hash because you never know when you'll need to search for those fields.

Also, if you `tell` a story inside a chapter block, your story will inherit the `event` and the `identifier` from the chapter so those will be indexed and searchable too.

## Exception handling

StoryTeller logs any exceptions that occur inside a chapter block. When an exception occurs, it will log it using an internal `StoryTeller.tell` invocation then *reraise the error* so any exception handling above the block can do its thing (bugsnag, or maybe recovering to show a 404, etc).

A `sev` fields mark the severity of a log. In normal logging event, that value will be set to `StoryTeller::Book::INFO_LEVEL`. However, when an exception bubbles to StoryTeller, the chapter will set the severity level of all stories to `StoryTeller::Book::ERROR_LEVEL`. It's often useful to filter by severity level so you can have an overview of all the logs that were involved for a given error.
## Stories Agent

