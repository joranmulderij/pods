import 'package:hive/hive.dart';
import 'package:hive_pods/hive_pods.dart';
import 'package:pods/pods.dart';
import 'package:test/test.dart';

void main() {
  test('Check if values are persisted', () async {
    Hive.init('./hive_box');
    await Hive.openBox('hive_box');
    final ref1 = StateContainer();
    final myHiveBoxPod = hiveBoxPod('hive_box');
    final myHivePod = hiveValuePod(myHiveBoxPod, 'test_1', 0);
    myHivePod.update(ref1, 1);
    expect(myHivePod.read(ref1), 1);

    final ref2 = StateContainer();
    expect(myHivePod.read(ref2), 1);
  });
}
