import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palo/model/image_data_model.dart';

class ImageView extends StatelessWidget {

  ImageDataModel image;
  Function onShare;
  Function onDownload;
  ImageView({super.key, required this.image, required this.onShare, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        CachedNetworkImage(
            fit: BoxFit.fitWidth,
            maxWidthDiskCache: 500,
            errorWidget: (context, url, error) => const Icon(Icons.error),
            placeholder: (context, url) => const SizedBox(width: 50, height:50, child: Center(child: CircularProgressIndicator())),
            imageUrl: image.downloadUrl
        ),

        Positioned(
            top: 8,
            right: 8,
            child: Column(
              children: [
                IconButton(
                    onPressed: (){
                      onShare();
                    }, icon: const Icon(Icons.share, color: Colors.white,)
                ),
                IconButton(
                    onPressed: (){
                      onDownload();
                    }, icon: const Icon(Icons.save_alt, color: Colors.white,)
                )
              ],
            )
        ),

        Positioned(
            top: 8,
            left: 8,
            child: Text(image.id, style: const TextStyle(color: Colors.white),)
        )

      ],
    );
  }
}
