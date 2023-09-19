import 'dart:io';

import 'package:drift/drift.dart' hide JsonKey;
import 'package:drift/native.dart';
import 'package:drift_pods/drift_pods.dart';
import 'package:drift_pods/drift_row.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pods/pods.dart';

part 'tables.freezed.dart';
part 'tables.g.dart';

final myDBPod = constPod(MyDatabase());

final driftPostPod = driftMutableRecordPod<DriftPost, DriftPostsCompanion,
    $DriftPostsTable, MyDatabase>(
  dbPod: myDBPod,
  tableInfo: (db) => db.driftPosts,
);

@freezed
class DriftPost
    with _$DriftPost
    implements DriftRow<DriftPost, DriftPostsCompanion> {
  const DriftPost._();

  const factory DriftPost({
    required int id,
    required String title,
    required String description,
  }) = _DriftPost;

  factory DriftPost.fromJson(Map<String, dynamic> json) =>
      _$DriftPostFromJson(json);

  @override
  DriftPostsCompanion toCompanion() {
    return DriftPostsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
    );
  }

  @override
  int getDriftRowId() => id;
}

@UseRowClass(DriftPost)
class DriftPosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
}

@DriftDatabase(tables: [DriftPosts])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = File('./data/db.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}

// /// FNV-1a 64bit hash algorithm optimized for Dart Strings
// int _fastHash(String string) {
//   var hash = 0xcbf29ce484222325;

//   var i = 0;
//   while (i < string.length) {
//     final codeUnit = string.codeUnitAt(i++);
//     hash ^= codeUnit >> 8;
//     hash *= 0x100000001b3;
//     hash ^= codeUnit & 0xFF;
//     hash *= 0x100000001b3;
//   }

//   return hash;
// }
