import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// The project's Realtime Database lives outside the default `us-central1`
/// region, so it needs an explicit URL rather than relying on
/// [FirebaseDatabase.instance] to infer one from `firebase_options.dart`.
final FirebaseDatabase appDatabase = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://onecitizen-bd-default-rtdb.asia-southeast1.firebasedatabase.app',
);

/// Field names that are written as [ServerValue.timestamp] (epoch millis)
/// and need converting back to ISO-8601 strings for the model `fromJson`
/// constructors, which expect plain JSON like the old mock REST layer used.
const _timestampFields = {
  'submitted_at',
  'updated_at',
  'uploaded_at',
  'dist_date',
  'created_at',
};

/// Merges a Realtime Database key into its data, converting the map's keys
/// to `String` (RTDB hands back `Map<Object?, Object?>`) and any epoch-millis
/// timestamp fields to ISO-8601 strings.
Map<String, dynamic> withKey(String key, Object? value) {
  final data = Map<String, dynamic>.from(value as Map? ?? {});
  for (final field in _timestampFields) {
    final v = data[field];
    if (v is int) {
      data[field] = DateTime.fromMillisecondsSinceEpoch(v).toIso8601String();
    }
  }
  return {'id': key, ...data};
}

/// Converts a query snapshot's children into a list of `{id, ...fields}`
/// maps, applying [withKey] to each.
List<Map<String, dynamic>> mapChildren(DataSnapshot snapshot) =>
    snapshot.children.map((child) => withKey(child.key!, child.value)).toList();
