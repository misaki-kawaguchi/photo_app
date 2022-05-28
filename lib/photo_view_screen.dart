import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photoapp/photo.dart';
import 'package:photoapp/providers.dart';

class PhotoViewScreen extends ConsumerStatefulWidget {
  const PhotoViewScreen({
    Key? key,
  }) : super(key: key);

  @override
  _PhotoViewScreenState createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends ConsumerState<PhotoViewScreen> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      // Riverpodから初期値を受け取り設定
      initialPage: ref.read(photoViewInitialIndexProvider),
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
          Consumer(builder: (context, ref, child) {
            final asyncPhotoList = ref.watch(photoListProvider);

            return asyncPhotoList.when(
              data: (photoList) {
                return PageView(
                  controller: _controller,
                  onPageChanged: (int index) => {},
                  children: photoList.map((Photo photo) {
                    return Image.network(
                      photo.imageURL,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                );
              },
              loading: () {
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (e, stackTrace) {
                return Center(
                  child: Text(e.toString()),
                );
              },
            );
          }),
          // ...
        ],
      ),
    );
  }
}
