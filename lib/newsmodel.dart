class Article {
  Source source;
  String author;
  String title;
  String imageUrl;
  String description;
  String url;
  DateTime publishedAt;

  Article({this.title, this.author, this.source, this.imageUrl, this.description, this.url, this.publishedAt});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: Source.fromJson(json["source"]),
      author: json["author"],
      title: json["title"],
      // description: json["description"],
      // url: json["url"],
      imageUrl: json["urlToImage"],
      description: json["description"],
      url: json["url"],
      publishedAt: DateTime.parse(json["publishedAt"])
    );
  }

}

class Source {
  String id;
  String name;

  Source({this.id, this.name});

  factory Source.fromJson(Map<String, dynamic> json){
    return Source(
        id: json['id'],
        name: json['name']
    );
  }
}