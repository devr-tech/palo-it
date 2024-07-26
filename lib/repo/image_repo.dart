import 'package:dartz/dartz.dart';
import 'package:palo/model/failure_model.dart';
import 'package:palo/model/image_data_model.dart';
import 'package:palo/service/image_api.dart';


class ImageRepository {
  final ImageAPI imageAPI;

  ImageRepository({
    required this.imageAPI,
  });


  Future<Either<FailureModel, List<ImageDataModel>>> getImageList(int pageNum) async {
    try {

      final result = await imageAPI.getImages(pageNum);

      return result.fold((l) {
        return left(l);
      }, (list) async {
        return right(list);
      });
    } catch (error) {
      return left(FailureModel(statusCode: 500, message: error.toString()));
    }
  }


}
