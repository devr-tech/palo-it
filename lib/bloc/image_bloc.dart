import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:palo/model/failure_model.dart';
import 'package:palo/model/image_data_model.dart';
import 'package:palo/repo/image_repo.dart';
import 'package:palo/service/image_api.dart';


part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {

  late ImageRepository repo;
  late ImageAPI imageAPI;
  late http.Client client;

  int pageNumber = 1;
  List<ImageDataModel> images = [];

  //Default constructor
  ImageBloc() : super(ImageState(images: null)) {
    client = http.Client();
    imageAPI = ImageAPI(client: client);
    repo = ImageRepository(
      imageAPI: imageAPI,
    );

    pageNumber = 1;
    images = [];

    _initialize();


  }

  _initialize() {

    on<GetImageList>((event, emit) async {
      try {
        if (event.firstLoad) {
          emit(ImageLoading(images: state.images));
        }
        if (state.hasLoadMore == false) {
          return;
        }
        final result = await imageAPI.getImages(event.pageNumber,);

        result.fold((failure) {
          emit(ImageError(failure: failure));
        }, (imageList) {
          final oldList = state.images;
          emit(
            ImageLoaded(
              images: [...oldList ?? [], ...imageList],
              hasLoadMore: true,
            ),
          );
        });
      } catch (err) {
        emit(
          ImageError(
            failure: FailureModel(
              statusCode: 500,
              message: err.toString(),
            ),
          ),
        );
      }
    });
  }
}
