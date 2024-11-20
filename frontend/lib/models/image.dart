class Image {
  final String? id;
  final String? path;
  final String? imagename;

  Image({
    this.id,
    this.path,
    this.imagename,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['id'],
      path: json['path'],
      imagename: json['imagename'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'imagename': imagename,
    };
  }
}
