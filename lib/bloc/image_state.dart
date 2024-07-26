part of 'image_bloc.dart';


class ImageState {

  List<ImageDataModel>? images = [];
  bool hasLoadMore = true;
  ImageState({
    this.images,
    this.hasLoadMore = true,
  });

}

class ImageLoading extends ImageState {
  ImageLoading({
    super.images,
  });

}

class ImageLoaded extends ImageState {
  ImageLoaded({super.images, super.hasLoadMore});
}

class ImageError extends ImageState {
  final FailureModel failure;
  ImageError({required this.failure});
}
