import 'package:drift/drift.dart';
import 'package:drift_pods/drift_row.dart';
import 'package:pods/pods.dart';

MutFamAsyncPod<T, int> driftMutableRecordPod<
    T extends DriftRow<T, Companion>,
    Companion extends Insertable<T>,
    Table extends TableInfo<Table, T>,
    DB extends GeneratedDatabase>({
  required Pod<DB> dbPod,
  required Table Function(DB db) tableInfo,
  // required Companion Function(T value) toCompanion,
}) {
  return MutFamAsyncPod<T, int>(
    onCreate: (ref, value) async {
      final db = ref.watch(dbPod());
      final table = tableInfo(db);
      return (await (db.into(table).insert(value.toCompanion())));
    },
    onRead: (ref, id) async {
      final db = ref.watch(dbPod());
      final table = tableInfo(db);
      final record = await (db.select(table)
            ..where((tbl) => tbl.rowId.equals(id)))
          .getSingle();
      return record;
    },
    onUpdate: (ref, id, value) async {
      final db = ref.watch(dbPod());
      final table = tableInfo(db);
      await (db.update(table)..where((tbl) => tbl.rowId.equals(id)))
          .write(value.toCompanion());
      return null;
    },
    onDelete: (ref, id) async {
      final db = ref.watch(dbPod());
      final table = tableInfo(db);
      await (db.delete(table)..where((tbl) => tbl.rowId.equals(id))).go();
    },
  );
}
