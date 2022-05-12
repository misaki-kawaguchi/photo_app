import 'package:flutter/material.dart';

class PhotoViewScreen extends StatefulWidget {
  const PhotoViewScreen({
    Key? key,
    required this.imageURL,
  }) : super(key: key);

  final String imageURL;

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late PageController _controller;

  final List<String> imageList = [
    'https://placehold.jp/400x300.png?text=0',
    'https://placehold.jp/400x300.png?text=1',
    'https://placehold.jp/400x300.png?text=2',
    'https://placehold.jp/400x300.png?text=3',
    'https://placehold.jp/400x300.png?text=4',
    'https://placehold.jp/400x300.png?text=5',
  ];

  @override
  void initState() {
    super.initState();

    final int initialPage = imageList.indexOf(widget.imageURL);
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
            children: imageList.map((String imageURL) {
              return Image.network(
                imageURL,
                fit: BoxFit.cover,
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
