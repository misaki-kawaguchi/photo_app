import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<void> addPhoto(File file) async {
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final String name = file.path.split('/').last;
    final String path = '${timestamp}_$name';
    final TaskSnapshot task = await FirebaseStorage.instance
        .ref()
        .child('users/${user.uid}/photos') // フォルダ名
        .child(path) // ファイル名
        .putFile(file); // 画像ファイル

    // アップロードした画像のURLを取得
    final String imageURL = await task.ref.getDownloadURL();
    // アップロードした画像の保村先を取得
    final String imagePath = task.ref.fullPath;
    final Photo photo = Photo(
      imageURL: imageURL,
      imagePath: imagePath,
      isFavorite: false,
    );
    
    await FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .doc()
        .set(_photoToMap(photo));
    
  }
  
  Map<String, dynamic> _photoToMap(Photo photo) {
    return {
      'imageURL': photo.imageURL,
      'imagePath': photo.imagePath,
      'isFavorite': photo.isFavorite,
      'createdAt': photo.createdAt == null
          ? Timestamp.now()
          : Timestamp.fromDate(photo.createdAt!)
    };
  }
}
