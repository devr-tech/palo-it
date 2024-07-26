import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:palo/model/failure_model.dart';
import 'package:palo/model/image_data_model.dart';

class ImageAPI {
  final http.Client client;


  ImageAPI({required this.client});

  Future<Either<FailureModel, List<ImageDataModel>>> getImages(int pageNum, int fetchedPerPage) async {
    try {

      final response = await client.get(
        Uri.parse("https://picsum.photos/v2/list?page=$pageNum&limit=$fetchedPerPage"),
      );

      if (response.statusCode < 300) {
        var list = json.decode(response.body) as List;
        List<ImageDataModel> images = list.map((i) => ImageDataModel.fromJson(i)).toList();
        return right(images);
      } else {
        return left(
          FailureModel(
            statusCode: response.statusCode,
            message: response.body.toString(),
          ),
        );
      }
    } catch (e) {
      return left(FailureModel(message: e.toString(), statusCode: 500));
    }
  }

}
