title: How to view documentation of callbacks in IEx for Elixir
date: 2019-03-20 09:36:03
tags:
- GenServer
- TIL
- Documentation
- Callbacks
---

The other day, I was playing around with GenServers when I needed to see the
documentation for the `handle_call` hook for a GenServer. I knew that this
wasn't a function defined on the `GenServer` so I couldn't just do a `h
GenServer.callback`. I thought to myself that there must be a way to get
callback documentation using `h`, so I typed `h h` in IEx.

```
iex(9)> h h

                                    def h()

Prints the documentation for IEx.Helpers.


                                defmacro h(term)

Prints the documentation for the given module or for the given function/arity
pair.

## Examples

    iex> h(Enum)

It also accepts functions in the format fun/arity and module.fun/arity, for
example:

    iex> h(receive/1)
    iex> h(Enum.all?/2)
    iex> h(Enum.all?)

iex(10)>
```

No luck with that! Nothing that references getting callback documentation, I
still wanted to do the naive thing and just see what `h GenServer.callback`
returned, to my surprise it ended up returning something useful:

```
iex(10)> h GenServer.handle_call
No documentation for function GenServer.handle_call was found, but there is a callback with the same name.
You can view callback documentation with the b/1 helper.

iex(11)>
```

Aha! I've been using Elixir for the past 3 years and I didn't know about `b`!
So, the next time you want to look up documentation about callbacks just use the
`b` helper in IEx, hope that saves you some time :) It even accepts a module and
shows you all the callbacks that a module defines!

P.S: The curse of knowledge is real, if I hadn't tried the naive way, I wouldn't
know that it was so easy to get documentation for callbacks and I would have
ended up creating a GenServer, sending a message and inspecting the arguments to
figure out what they were. So, the next time you run into a problem, it might be
worth your while to take a step back and ask yourself, How would an Elixir
beginner do this?

```
iex(13)> b GenServer.handle_call
@callback handle_call(request :: term(), from(), state :: term()) ::
            {:reply, reply, new_state}
            | {:reply, reply, new_state,
               timeout() | :hibernate | {:continue, term()}}
            | {:noreply, new_state}
            | {:noreply, new_state,
               timeout() | :hibernate | {:continue, term()}}
            | {:stop, reason, reply, new_state}
            | {:stop, reason, new_state}
          when reply: term(), new_state: term(), reason: term()

Invoked to handle synchronous call/3 messages. call/3 will block until a reply
is received (unless the call times out or nodes are disconnected).

request is the request message sent by a call/3, from is a 2-tuple containing
the caller's PID and a term that uniquely identifies the call, and state is the
current state of the GenServer.

Returning {:reply, reply, new_state} sends the response reply to the caller and
continues the loop with new state new_state.

Returning {:reply, reply, new_state, timeout} is similar to {:reply, reply,
new_state} except handle_info(:timeout, new_state) will be called after timeout
milliseconds if no messages are received.

Returning {:reply, reply, new_state, :hibernate} is similar to {:reply, reply,
new_state} except the process is hibernated and will continue the loop once a
message is in its message queue. If a message is already in the message queue
this will be immediately. Hibernating a GenServer causes garbage collection and
leaves a continuous heap that minimises the memory used by the process.

Returning {:reply, reply, new_state, {:continue, continue}} is similar to
{:reply, reply, new_state} except c:handle_continue/2 will be invoked
immediately after with the value continue as first argument.

Hibernating should not be used aggressively as too much time could be spent
garbage collecting. Normally it should only be used when a message is not
expected soon and minimising the memory of the process is shown to be
beneficial.

Returning {:noreply, new_state} does not send a response to the caller and
continues the loop with new state new_state. The response must be sent with
reply/2.

There are three main use cases for not replying using the return value:

  • To reply before returning from the callback because the response is
    known before calling a slow function.
  • To reply after returning from the callback because the response is not
    yet available.
  • To reply from another process, such as a task.

When replying from another process the GenServer should exit if the other
process exits without replying as the caller will be blocking awaiting a reply.

Returning {:noreply, new_state, timeout | :hibernate | {:continue, continue}}
is similar to {:noreply, new_state} except a timeout, hibernation or continue
occurs as with a :reply tuple.

Returning {:stop, reason, reply, new_state} stops the loop and c:terminate/2 is
called with reason reason and state new_state. Then the reply is sent as the
response to call and the process exits with reason reason.

Returning {:stop, reason, new_state} is similar to {:stop, reason, reply,
new_state} except a reply is not sent.

This callback is optional. If one is not implemented, the server will fail if a
call is performed against it.

iex(14)>
```
