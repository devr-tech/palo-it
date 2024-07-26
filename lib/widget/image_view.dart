import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palo/model/image_data_model.dart';

class ImageView extends StatelessWidget {

  ImageDataModel image;
  Function onTap;
  ImageView({super.key, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: CachedNetworkImage(
          fit: BoxFit.contain,
          maxWidthDiskCache: 500,
          maxHeightDiskCache: 500,
          errorWidget: (context, url, error) => const Icon(Icons.error),
          placeholder: (context, url) => const SizedBox(width: 50, height:50, child: Center(child: CircularProgressIndicator())),
          imageUrl: image.downloadUrl
      ),
    );
  }
}
