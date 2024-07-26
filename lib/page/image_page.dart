import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palo/bloc/image_bloc.dart';
import 'package:palo/widget/image_view.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {

  final _scrollController = ScrollController();
  bool _isFetching = false;

  int _pageNumber = 1;

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
      context.read<ImageBloc>().add(GetImageList(pageNumber: _pageNumber, firstLoad: false));
      print("bottom ");
    }


  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Page'),
      ),
      body: BlocConsumer<ImageBloc, ImageState>(
        bloc: BlocProvider.of<ImageBloc>(context)
          ..add(GetImageList(pageNumber: _pageNumber, firstLoad: true)),
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
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.images!.length,
              itemBuilder: (context, index) {

                if (index >= state.images!.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final image = state.images![index];
                return ImageView(image: image, onTap: (){

                });
              },
            );
          } else {
            return const Center(
              child: Text('Something went wrong!'),
            );
          }
        },
      ),
    );
  }
}
