import 'package:drift/drift.dart';

abstract class DriftRow<T, Companion extends Insertable<T>> {
  Companion toCompanion();

  int getDriftRowId();
}
