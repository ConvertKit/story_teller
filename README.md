# StoryTeller

Create indexable and searchable logs by using the two methods that StoryTeller uses to build structured logs around features. The power of StoryTeller lies in its ability to add more context to your logs without you needing to pass properties around in your code just to get more information.

Log request params, or conditions paths with `StoryTeller.tell` and wrap everything inside a `StoryTeller.chapter` at the controller level and you will be able to follow a request down to figure out exactly what happened and why things happened in the way that they did.

## Core Concepts
There is 3 classes that build most of StoryTeller's logic and features: `StoryTeller::Book`, `StoryTeller::Chapter` and `StoryTeller::Story`. These are internal objects and you shouldn't need to be exposed to those but it's still worthwhile to understand how things work under the hood.

### Book
A book is an object that is created lazily as soon as an call is made to `StoryTeller.tell` or `StoryTeller.chapter`. Even though these 2 are class methods, StoryTeller is thread safe because it always refers to a book for the current thread. If a thread doesn't have a book, it will create one.

Each book has its own `UUID` that is going to be used by all stories and chapters so you can filter logs by request/jobs. That is particularly useful when you see something weird in the log and you want to follow step by step all the logs for a request.

### Chapter
Chapter is what is created when invoking `StoryTeller.chapter(title:, subtitle:, &block)`. The chapter is a context that is created for all the logs that are going to occur inside the block that is passed. If you have a controller action that instantiates an object which, in turn, does a lot of things that you'd like to log, you should call `StoryTeller.chapter(title:, subtitle:, &block)` and do all the processing inside the block.

This way, StoryTeller will be able to assign all the logs to a given resource and event. This, in turn will make it possible for you to search for all the logs that happened on event XYZ with resource ABC.

```
class BooksController < ApplicationController
  def purchase
    @purchase = Purchase.create(@integration, params[:orders])
  end
  around_action only: :purchase do |_, action|
    StoryTeller.with("Books::Purchase", @integration) do
      action.call
    end
  end
end
```

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

### Integrations with 3rd parties

