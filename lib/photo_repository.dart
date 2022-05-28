import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photoapp/photo.dart';

class PhotoRepository {
  PhotoRepository(this.user);
  final User user;
  
  Stream<List<Photo>> getPhotoList() {
    return FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .orderBy('createdAt', descending: true)
        .snapshots().map(_queryToPhotoList);
  }

  List<Photo> _queryToPhotoList(QuerySnapshot query) {
    return query.docs.map((doc) {
      return Photo(
        id: doc.id,
        imageURL: doc.get('imageURL'),
        imagePath: doc.get('imagePath'),
        isFavorite: doc.get('isFavorite'),
        createdAt: (doc.get('createdAt') as Timestamp).toDate(),
      );
    }).toList();
  }
}
