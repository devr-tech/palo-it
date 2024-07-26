part of 'image_bloc.dart';

abstract class ImageEvent {
  const ImageEvent();
}

class GetImageList extends ImageEvent {
  final int pageNumber;
  final bool firstLoad;

  const GetImageList({
    required this.pageNumber,
    required this.firstLoad,
  });
}