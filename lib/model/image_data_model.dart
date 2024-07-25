
class ImageDataModel {
  String id;
  String author;
  String url;
  String downloadUrl;

  ImageDataModel({required this.id, required this.author, required this.url, required this.downloadUrl});

  factory ImageDataModel.fromJson(Map<String, dynamic> json) {
    return ImageDataModel(
        id: json['id'],
        author: json['author'],
        url: json['url'],
        downloadUrl: json['download_url']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'url': url,
      'download_url': downloadUrl
    };
  }


}