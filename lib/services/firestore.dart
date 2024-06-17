import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Get notes collection from Firestore
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('todos');

  // CREATE: add a new to do
  Future<void> addToDo(String todo) {
    return notes.add({
      'todo': todo,
      'done': false,
      'timestamp': Timestamp.now(),
    });
  }

  // READ: get to dos from Firestore
  Stream<QuerySnapshot> getToDoStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  // UPDATE: updates to do given a document ID
  Future<void> updateToDo(String docId, String text) {
    return notes.doc(docId).update({
      'todo': text,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> toggleToDo(String docId, bool done) {
    return notes.doc(docId).update({
      'done': done,
    });
  }

  // DELETE: delete to do given a document ID
  Future<void> deleteToDo(String documentId) {
    return notes.doc(documentId).delete();
  }
}
