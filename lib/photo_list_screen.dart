import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photoapp/photo.dart';
import 'package:photoapp/photo_repository.dart';
import 'package:photoapp/photo_view_screen.dart';
import 'package:photoapp/sign_in_screen.dart';

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({Key? key}) : super(key: key);

  @override
  State<PhotoListScreen> createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  late int _currentIndex;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    // PageViewで表示されているWidgetの番号を持っておく
    _currentIndex = 0;
    // PageViewの表示を切り替えるのに使う
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    // ログインしているユーザーの情報を取得
    final User user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo App'),
        actions: [
          IconButton(
            onPressed: _onSignOut,
            icon: const Icon(
              Icons.exit_to_app,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Photo>>(
        // Cloud Firestoreからデータを取得
        stream: PhotoRepository(user).getPhotoList(),
        builder: (context, snapshot) {
          // Cloud Firestoreからデータを取得中の場合
          if (snapshot.hasData == false) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Cloud Firestoreからデータを取得完了した場合
          final List<Photo> photoList = snapshot.data!;
          return PageView(
            controller: _controller,
            onPageChanged: (int index) => _onPageChanged(index),
            children: [
              //「全ての画像」を表示する部分
              PhotoGridView(
                // Cloud Firestoreから取得した画像のURL一覧を渡す
                photoList: photoList,
                onTap: (photo) => _onTapPhoto(photo, photoList),
              ),
              //「お気に入り登録した画像」を表示する部分
              PhotoGridView(
                // お気に入り登録した画像は、後ほど実装
                photoList: photoList,
                onTap: (photo) => _onTapPhoto(photo, photoList),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddPhoto(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => _onTapBottomNavigationItem(index),
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'フォト',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'お気に入り',
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTapBottomNavigationItem(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTapPhoto(Photo photo, List<Photo> photoList) {
    // 最初に表示する画像のURLを指定して、画像詳細画面に切り替える
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewScreen(
          photo: photo,
          photoList: photoList,
        ),
      ),
    );
  }

  // ログアウト
  Future<void> _onSignOut() async {
    // ログアウト処理
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SignInScreen(),
      ),
    );
  }
}

// 画像追加用ボタンをタップした時の処理
Future<void> _onAddPhoto() async {
  // 画像ファイルを選択
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );

  // 画像ファイルが選択された場合
  if (result != null) {
    // ログイン中のユーザー情報を取得
    final User user = FirebaseAuth.instance.currentUser!;

    // フォルダとファイル名を指定し画像をアップロード
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final File file = File(result.files.single.path!);
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
    // データ
    final data = {
      'imageURL': imageURL,
      'imagePath': imagePath,
      'isFavorite': false,
      'createdAt': Timestamp.now(),
    };

    // データをCloud FireStoreに保存
    await FirebaseFirestore.instance
        .collection('users/${user.uid}/photos') // コレクション
        .doc() // ドキュメント（何も指定しない場合は自動的にIDが決まる）
        .set(data); // データ
  }
}

// Widgetを新たに定義し再利用できる
class PhotoGridView extends StatelessWidget {
  const PhotoGridView({
    Key? key,
    // 引数から画像のURL一覧を受け取る
    required this.photoList,
    required this.onTap,
  }) : super(key: key);

  final List<Photo> photoList;
  // コールバックからタップされた画像のURLを受け渡す
  final Function(Photo photo) onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      children: photoList.map((Photo photo) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: InkWell(
                onTap: () => onTap(photo),
                child: Image.network(
                  photo.imageURL,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {},
                color: Colors.white,
                icon: const Icon(Icons.favorite_border),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
