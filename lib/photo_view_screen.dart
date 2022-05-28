import 'package:flutter/material.dart';
import 'package:photoapp/photo.dart';

class PhotoViewScreen extends StatefulWidget {
  const PhotoViewScreen({
    Key? key,
    // StringではなくPhotoで受け取る
    required this.photo,
    // 引数から画像のURL一覧を受け取る
    required this.photoList,
  }) : super(key: key);

  final Photo photo;
  final List<Photo> photoList;

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    // 受け取った画像一覧から、ページ番号を特定
    final int initialPage = widget.photoList.indexOf(widget.photo);

    _controller = PageController(
      initialPage: initialPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBarの裏までbodyの表示エリアを広げる
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 画像一覧
          PageView(
            controller: _controller,
            onPageChanged: (int index) => {},
            children: widget.photoList.map((Photo photo) {
              return Image.network(
                photo.imageURL,
                fit: BoxFit.contain,
              );
            }).toList(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              // フッター部分にグラデーションを入れてみる
              decoration: BoxDecoration(
                // 線形グラデーション
                gradient: LinearGradient(
                  // 下方向から上方向に向かってグラデーションさせる
                  begin: FractionalOffset.bottomCenter,
                  end: FractionalOffset.topCenter,
                  // 半透明の黒から透明にグラデーションさせる
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 共有ボタン
                  IconButton(
                    onPressed: () => {},
                    color: Colors.white,
                    icon: const Icon(Icons.share),
                  ),
                  // 削除ボタン
                  IconButton(
                    onPressed: () => {},
                    color: Colors.white,
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
