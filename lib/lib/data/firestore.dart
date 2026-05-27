import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  static final _instance = FirebaseFirestore.instance;

  String collection;
  Firestore(this.collection);

  Future<DocumentSnapshot> getDoc(String id) => _instance.collection(collection).doc(id).get();
  Future<void> setDoc(DocumentSnapshot snapshot, Map<String, dynamic> data) async {
    final doc = _instance.collection(collection).doc(snapshot.id);

    if (!snapshot.exists) doc.set(data);
    else {
      bool diff = false;
      final cloudData = snapshot.data() as Map<String, dynamic>;
      for (MapEntry<String, dynamic> entry in data.entries)
        if (entry.value != cloudData[entry.key]) {
          diff = true;
          break;
        }

      if (diff) doc.update(data);
    }
  }
}