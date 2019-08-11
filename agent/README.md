# Stories

Stories is a lightweight agent for StoryTeller logs.

## Configuration

Currently, the agent has a hardcoded dependency to Scalyr as a provider. This means that the agent will look for the `SCALYR_WRITE_TOKEN` Environment variable to be set. Other than that, `stories` can be configured with the following flags at startup.

*`--buffer=int`*

_default: 1000_
The buffer size is how many stories that the agent can store before it sends it in a batch to the provider.

*`--interval=int`*

_default: 1_

The interval, in seconds, before the agent batch the stories that it has buffered.


*`--socket=string`*

_default: /tmp/stories.sock_

The path where the unix socket will be created. This is used by libraries to send over events.


*`--debug=boolean`*

_default: false_

If you want to see debug logs, you need to set this to `true`. This should not be switched on in production.

#### Batching against an interval

The way the agent works is that there is a runloop set to the `interval` set at runtime that will send in batch any stories that were collected during the interval.

If, during the interval, the buffer reach its limit, the agent will trigger a batch send to the provider. If all default settings are set and you send twice the size of the buffer over the interval period, 2 batch will be sent to the provider.


## Data Structure of a payload
A structured log sent to this agent expects a certain structure.

```
{
  "timestamp": "542632806622183000",
  "severity": 3,
  "message": "A test message",
  "data": {
    "uuid": "be739c8e-191c-40fd-af94-b6922e38b184",
    "event":"Global",
    "identifier":"nil"
  }
}
```

`timestamp` is the unix timestamp, in nanoseconds.

`severity` is the log level for this message. It defaults to 3 (optional).

`message` is the message you want to appear for this log.

`data` is where all the user info is displayed. You can add as much data as you want.

