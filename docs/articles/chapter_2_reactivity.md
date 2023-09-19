# Chapter 2 - Reactivity

Now we have a really nice and simple model for where state goes there is just one flaw with this design. There are potentially many places in the UI where the same state is consumed. There are also potentially many places from which this state is mutated. You cannot make the UI layer responsible for updating when it updates some state, because other widgets consuming the same state will not update. 

This is where reactivity comes in. Instead of referencing the state, you listen to it. Every time the state changes - it does not matter what causes this to happen - the UI should update. This also forms the number one rule in state management:

> Never copy data without listening to changes

This rules should be met for UI listening to the state machine, as well as different components within the state machine talking to each other.
## Reactivity with the server

Remember that the state machine includes the server? This means that technically the above rule should be applied to the server-client connection. This turns out to be really difficult. There are ways to listen to state on the server, namely WebSockets. WebSockets, however, are not really performant, and overkill in most cases where you can assume the server state to not change often.

Ok, so we drop the above rule for server-client communication, but what if the user mutates some data that needs to be synced to the server? A message is sent to the server that mutates the server state, but now the client is behind on data that it just made. In most cases this is a problem, since it will be noticeable to the user.

The solution is to keep a mutable copy of the data on the client. When the user wants to update some data, a message is sent to the server, and at the same time the local copy is updated with the new data. Later chapters will go into detail on how this is done.

Reactivity with a local database is handled in almost the same way. The only difference is that network request fail way more often than interactions with a local database, and when the local database does fail, there is no reason to believe that it will suddenly start working at a later time.

In [the next chapter](chapter_3_state_machine) we will look at the different components that make up a state machine.