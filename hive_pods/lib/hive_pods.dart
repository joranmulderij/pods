import 'package:hive/hive.dart';
import 'package:pods/pods.dart';

ImmutablePod<Box> hiveBoxPod(String name) {
  return constPod(Hive.box(name));
}

MutPod<T> hiveValuePod<T>(
    ImmutablePod<Box> hiveBoxPod, String key, T defaultValue) {
  return MutPod(
    onRead: (ref) => hiveBoxPod.read(ref).get(key, defaultValue: defaultValue),
    onUpdate: (ref, value) => hiveBoxPod.read(ref).put(key, value),
    onReset: (ref) => hiveBoxPod.read(ref).delete(key),
  );
}
