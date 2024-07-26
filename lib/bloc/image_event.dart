part of 'image_bloc.dart';

abstract class ImageEvent {
  const ImageEvent();
}

class GetImageList extends ImageEvent {
  final int pageNumber;
  final bool firstLoad;
  int fetchedPerPage = 10; //default value

  GetImageList({
    required this.pageNumber,
    required this.firstLoad,
    required this.fetchedPerPage,
  });
}