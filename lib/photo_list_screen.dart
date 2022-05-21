import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
      body: PageView(
        controller: _controller,
        // 表示が切り替わった時
        onPageChanged: (int index) => _onPageChanged(index),
        children: [
          // 全ての画像を表示
          PhotoGridView(
            // コールバックを設定しタップした画像のURLを受け取る
            onTap: (imageURL) => _onTapPhoto(imageURL),
          ),
          PhotoGridView(
            // コールバックを設定しタップした画像のURLを受け取る
            onTap: (imageURL) => _onTapPhoto(imageURL),
          ),
        ],
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

  void _onTapPhoto(String imageURL) {
    // 最初に表示する画像のURLを指定して、画像詳細画面に切り替える
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoViewScreen(imageURL: imageURL),
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
  }
}

class PhotoGridView extends StatelessWidget {
  const PhotoGridView({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  // コールバックからタップされた画像のURLを受け渡す
  final void Function(String imageURL) onTap;

  @override
  Widget build(BuildContext context) {
    // ダミー画像一覧
    final List<String> imageList = [
      'https://placehold.jp/400x300.png?text=0',
      'https://placehold.jp/400x300.png?text=1',
      'https://placehold.jp/400x300.png?text=2',
      'https://placehold.jp/400x300.png?text=3',
      'https://placehold.jp/400x300.png?text=4',
      'https://placehold.jp/400x300.png?text=5',
    ];
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      children: imageList.map((String imageURL) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: InkWell(
                onTap: () => onTap(imageURL),
                child: Image.network(
                  imageURL,
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
