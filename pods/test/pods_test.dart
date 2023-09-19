import 'package:pods/pods.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('MutPod', () {
    test('MutPod update', () {
      final ref = ProviderContainer();
      var onUpdateCalled = false;
      var callbackCalled = false;
      final myPod = MutPod(
        onRead: (ref) => 1,
        onUpdate: (ref, value) {
          onUpdateCalled = true;
          expect(value, 2);
        },
      );
      ref.listen(myPod(), (previous, next) {
        callbackCalled = true;
        expect(next, 2);
      });
      expect(ref.read(myPod()), 1);
      ref.read(myPod().notifier).put(2);
      expect(ref.read(myPod()), 2);
      expect(callbackCalled, true);
      expect(onUpdateCalled, true);
    });
    test('MutPod reset', () {
      final ref = ProviderContainer();
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
      ref.listen(myPod(), (previous, next) {
        callbackCalled = true;
      });
      expect(onUpdateCalled, false);
      expect(ref.read(myPod()), 1);
      ref.read(myPod().notifier).put(2);
      expect(ref.read(myPod()), 2);
      ref.read(myPod().notifier).delete();
      expect(ref.read(myPod()), 1);
      expect(callbackCalled, true);
      expect(onUpdateCalled, true);
      expect(onResetCalled, true);
    });
    test('MutPod onUpdate error', () {
      final ref = ProviderContainer();
      final myPod = MutPod(
        onRead: (ref) => 1,
        onUpdate: (ref, value) {
          throw Exception('onUpdate error');
        },
      );
      expect(ref.read(myPod()), 1);
      expect(() => ref.read(myPod().notifier).put(2), throwsException);
      expect(ref.read(myPod()), 1);
    });
    test('MutPod onReset error', () {
      final ref = ProviderContainer();
      final myPod = MutPod(
        onRead: (ref) => 1,
        onReset: (ref) {
          throw Exception('onReset error');
        },
      );
      expect(ref.read(myPod()), 1);
      ref.read(myPod().notifier).put(2);
      expect(ref.read(myPod()), 2);
      expect(() => ref.read(myPod().notifier).delete(), throwsException);
      expect(ref.read(myPod()), 2);
    });
    test('MutPod onRead error', () {
      final ref = ProviderContainer();
      final myPod = MutPod(
        onRead: (ref) {
          throw Exception('onRead error');
        },
      );
      expect(() => ref.read(myPod()), throwsException);
    });
  });
  test('constPod', () {
    final ref = ProviderContainer();
    final myPod = constPod(1);
    expect(ref.read(myPod()), 1);
  });
}
