import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import 'tables.dart';

void main() {
  test('Write to DB and read it afterwards', () async {
    final ref = ProviderContainer();
    final posts = List.generate(
        100,
        (index) => DriftPost(
              id: index,
              title: 'Title-$index',
              description: 'Description-$index',
            ));
    final db = ref.read(myDBPod());
    await db.delete(db.driftPosts).go();
    for (final post in posts) {
      await db.into(db.driftPosts).insert(post.toCompanion());
    }
    for (int i = 0; i < 100; i++) {
      expect(await ref.read(driftPostPod(i).future), posts[i]);
    }
    expect(await ref.read(driftPostPod(99).future), isNot(posts[98]));
  });
}
