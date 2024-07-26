import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:palo/bloc/image_bloc.dart';
import 'package:palo/widget/image_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {

  final _scrollController = ScrollController();
  bool _isFetching = false;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  int _pageNumber = 1;
  int _fetchedPerPage = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !_isFetching) {
      _pageNumber++;
      _isFetching = true;
      context.read<ImageBloc>().add(GetImageList(pageNumber: _pageNumber, firstLoad: false, fetchedPerPage: _fetchedPerPage));
    }


  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.8);
  }

  _refresh() {
    _pageNumber = 1;
    context.read<ImageBloc>().add(GetImageList(pageNumber: _pageNumber, firstLoad: true, fetchedPerPage: _fetchedPerPage));
  }
  Future<void> _showFetchPerPagePrompt(BuildContext context) async {
    TextEditingController textController = TextEditingController();
    textController.text = _fetchedPerPage.toString();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Number of Images to Fetch Per Page'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Number of Images"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {

                try {
                  _fetchedPerPage = int.parse(textController.text);
                  _refresh();
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid number"),
                    ),
                  );
                  return;
                }


              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showFetchPerPagePrompt(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<ImageBloc, ImageState>(
        bloc: BlocProvider.of<ImageBloc>(context)
          ..add(GetImageList(pageNumber: _pageNumber, firstLoad: true, fetchedPerPage: _fetchedPerPage)),
        listener: (context, state) {
          if (state is ImageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
              ),
            );

            _isFetching = false;
          } else if (state is ImageLoaded) {
            _isFetching = false;
          }
        },
        builder: (context, state) {
          if (state is ImageLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ImageLoaded) {
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: () {
                _pageNumber = 1;
                context.read<ImageBloc>().add(GetImageList(pageNumber: _pageNumber, firstLoad: true, fetchedPerPage: _fetchedPerPage));
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.images!.length,
                itemBuilder: (context, index) {
              
                  if (index >= state.images!.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
              
                  final image = state.images![index];
                  return ImageView(image: image, onDownload: () async {

                    final url = Uri.parse(image.downloadUrl);
                    final response = await http.get(url);
                    final Directory tempDir = await getTemporaryDirectory();
                    File f = await File('${tempDir.path}/myItem.png').writeAsBytes(response.bodyBytes);

                    GallerySaver.saveImage(f.path).then((bool? success) {

                      if (success!) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image saved to gallery'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save image to gallery'),
                          ),
                        );
                      }
                    });
              
                  }, onShare: () async {
                    final url = Uri.parse(image.downloadUrl);
                    final response = await http.get(url);
                    final Directory tempDir = await getTemporaryDirectory();
                    await File('${tempDir.path}/myItem.png').writeAsBytes(response.bodyBytes);
                    await Share.shareXFiles([XFile('${tempDir.path}/myItem.png')]);
                  },);
                },
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Something went wrong!'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                     _refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
