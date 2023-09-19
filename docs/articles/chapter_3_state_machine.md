# Chapter 3 - State machine

## State machine job description
So what is such a state machine? Let's think about what it should really do. It has quite a number of jobs:
- Storing data
- Providing a way to mutate it's state
- Ensuring that invalid states cannot exist
- Handling server-client communication

That is quite a job description. Let go through them one by one.
### Storing data
Storing data is probably the easiest of them all. You just hold a variable somewhere. In order to do this properly, let encapsulate them in `Pods`. Take a look a the code below:
```dart
final container = ProviderContainer();
final myValuePod = Pod<int>((ref) => 0);
print(container.read(myValuePod())); // 0
```
### Providing state mutation handles
Providing state mutation handles is not that hard. Just turn your pod into a mutable pod:
```dart
final myValuePod = MutPod<int>((ref) => 0);
container.read(myValuePod.notifier()).update(5);
print(container.read(myValuePod())); // 5
```

You can also reset the state:
```dart
container.read(myValuePod.notifier()).reset();
print(container.read(myValuePod())); // 0
```

Furthermore you can define an `onUpdate` callback:
```dart
final myValuePod = MutPod<int>(
  (ref) => 0,
  onUpdate: (ref, value) {
    print("Updated!");
  },
);
container.read(myValuePod.notifier()).update(5); // prints "Updated!"
```

This can be used to create a persistent provider using a persistence library, for example `hive`:
```dart
final myHivePod = hiveBoxPod('./data');
final myValuePod = hivePod<int>('my_value', myHivePod, (ref) => 0);
// 'my_value' has been set to 5 some time ago.
print(container.read(myValuePod())); // 5
```

> Note: in contrast to `riverpod` providers, `pods` also have type safe mutation handles.

## Creating a state machine
A state machine is constructed by just passing `pods` to each other. Pods that are passed into other pods are called "parent" pods. When the state of any of the parent pods changes, the child pod is rebuilt.

The way in which these pods interact is defined at compile time. The state machine cannot change it's own structure. This also means that the structure of the state machine could be drawn out, for example a diagram.

> The structure of the state machine is static

## Standard pods
In the code snippets above there were a couple examples of pods created around packages. These handle all the communication with the package, while the API layer with the resulting pods is no different than any other pod. This is where the power of this standard interface really shows. You just create a `hivePod` and from that point on you don't have to think about persistence again, since everything is contained in the pod.

In the `hivePod` example, full reactivity is guaranteed as long as there is only one pod per key, and the hive data store is only accessed through pods. The same could be done for interactions with APIs or a backend.

## Pods as building blocks
That is really the correct way of looking at it. You use pods to *statically* build up the way the state machine is supposed to function. You can build your own pods for functionality that is not already implemented by someone, which will happen often, since every application has different functionality and requirements. Some things are just difficult, like caching, which we will look at in the next chapter. Since pods can handle two way data flow, and are completely customizable in how they function, anything can be modeled using a combination of premade and custom made pods.

[Next chapter: Caching](chapter_4_caching)
