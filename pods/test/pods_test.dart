import 'package:pods/pods.dart';
import 'package:test/test.dart';

void main() {
  group('MutPod', () {
    test('MutPod update', () {
      final ref = StateContainer();
      var onUpdateCalled = false;
      var callbackCalled = false;
      final myPod = MutPod(
        onRead: (ref) => 1,
        onUpdate: (ref, value) {
          onUpdateCalled = true;
          expect(value, 2);
        },
      );
      myPod.listen(ref, (previous, next) {
        callbackCalled = true;
        expect(next, 2);
      });
      expect(myPod.read(ref), 1);
      myPod.update(ref, 2);
      expect(myPod.read(ref), 2);
      expect(callbackCalled, true);
      expect(onUpdateCalled, true);
    });
    test('MutPod reset', () {
      final ref = StateContainer();
      var onResetCalled = false;
      var onUpdateCalled = false;
      var callbackCalled = false;
      final myPod = MutPod(
        onRead: (ref) => 1,
        onReset: (ref) {
          onResetCalled = true;
        },
        onUpdate: (ref, value) {
          onUpdateCalled = true;
        },
      );
      myPod.listen(ref, (previous, next) {
        callbackCalled = true;
      });
      expect(onUpdateCalled, false);
      expect(myPod.read(ref), 1);
      myPod.update(ref, 2);
      expect(myPod.read(ref), 2);
      myPod.reset(ref);
      expect(myPod.read(ref), 1);
      expect(callbackCalled, true);
      expect(onUpdateCalled, true);
      expect(onResetCalled, true);
    });
    test('MutPod onUpdate error', () {
      final ref = StateContainer();
      final myPod = MutPod(
        onRead: (ref) => 1,
        onUpdate: (ref, value) {
          throw Exception('onUpdate error');
        },
      );
      // expect(ref.read(myPod()), 1);
      expect(myPod.read(ref), 1);

      expect(() => myPod.update(ref, 2), throwsException);
      expect(myPod.read(ref), 1);
    });
    test('MutPod onReset error', () {
      final ref = StateContainer();
      final myPod = MutPod(
        onRead: (ref) => 1,
        onReset: (ref) {
          throw Exception('onReset error');
        },
      );
      expect(myPod.read(ref), 1);
      myPod.update(ref, 2);
      expect(myPod.read(ref), 2);
      expect(() => myPod.reset(ref), throwsException);
      expect(myPod.read(ref), 2);
    });
    test('MutPod onRead error', () {
      final ref = StateContainer();
      final myPod = MutPod(
        onRead: (ref) {
          throw Exception('onRead error');
        },
      );
      expect(() => myPod.read(ref), throwsException);
    });
  });
  group('MutFamPod', () {
    test('MutFamPod update', () {
      final ref = StateContainer();
      var onUpdateCalled = false;
      final myPod = MutFamPod<int, int>(
        onRead: (ref, arg) => 1,
        onUpdate: (ref, arg, value) {
          onUpdateCalled = true;
          expect(value, 2);
        },
        onDelete: (ref, arg) {},
        onCreate: (ref, arg, value) {},
      );
      expect(myPod.read(ref, 1), 1);
      myPod.update(ref, 1, 2);
      expect(onUpdateCalled, true);
    });
    test('mapPod', () {
      final ref = StateContainer();
      final myPod = mapPod<int, String>();
      expect(myPod.read(ref, 1), null);
      myPod.update(ref, 1, 'one');
      expect(myPod.read(ref, 1), 'one');
      myPod.update(ref, 1, 'two');
      expect(myPod.read(ref, 1), 'two');
      myPod.delete(ref, 1);
      expect(myPod.read(ref, 1), null);
    });
  });
  test('constPod', () {
    final ref = StateContainer();
    final myPod = constPod(1);
    expect(myPod.read(ref), 1);
  });
}
