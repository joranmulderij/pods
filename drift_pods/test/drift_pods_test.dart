import 'package:pods/pods.dart';
import 'package:test/test.dart';

import 'tables.dart';

void main() {
  test('Write to DB and read it afterwards', () async {
    final ref = StateContainer();
    final posts = List.generate(
        100,
        (index) => DriftPost(
              id: index,
              title: 'Title-$index',
              description: 'Description-$index',
            ));
    final db = myDBPod.read(ref);
    await db.delete(db.driftPosts).go();
    for (final post in posts) {
      await db.into(db.driftPosts).insert(post.toCompanion());
    }
    for (int i = 0; i < 100; i++) {
      expect(await driftPostPod.readFuture(ref, i), posts[i]);
    }
    expect(await driftPostPod.readFuture(ref, 99), isNot(posts[98]));
  });
}
