import 'package:hive/hive.dart';
import 'package:pods/pods.dart';

Pod<Box> hiveBoxPod(String name) {
  return constPod(Hive.box(name));
}

MutPod<T> hiveValuePod<T>(Pod<Box> hiveBoxPod, String key, T defaultValue) {
  return MutPod(
    onRead: (ref) =>
        ref.read(hiveBoxPod()).get(key, defaultValue: defaultValue),
    onUpdate: (ref, value) => ref.read(hiveBoxPod()).put(key, value),
    onReset: (ref) => ref.read(hiveBoxPod()).delete(key),
  );
}
