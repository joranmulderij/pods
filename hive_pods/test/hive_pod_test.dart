import 'package:hive/hive.dart';
import 'package:hive_pods/hive_pods.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  test('Check if values are persisted', () async {
    Hive.init('./hive_box');
    await Hive.openBox('hive_box');
    final ref1 = ProviderContainer();
    final myHiveBoxPod = hiveBoxPod('hive_box');
    final myHivePod = hiveValuePod(myHiveBoxPod, 'test_1', 0);
    ref1.read(myHivePod.notifier()).put(1);
    expect(ref1.read(myHivePod()), 1);

    final ref2 = ProviderContainer();
    expect(ref2.read(myHivePod()), 1);
  });
}
