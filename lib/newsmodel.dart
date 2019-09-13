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
    DateTime date;
    try {
      date = DateTime.parse(json["publishedAt"]);
    } catch (ex) {
      date = DateTime.now();
    }
    return Article(
      source: Source.fromJson(json["source"]),
      author: json["author"],
      title: json["title"],
      // description: json["description"],
      // url: json["url"],
      imageUrl: json["urlToImage"],
      description: json["description"],
      url: json["url"],
      publishedAt: date
    );
  }

}

class Source {
  String id;
  String name;
  String description;
  String url;

  Source({this.id, this.name});
  Source.fullSource({this.id, this.name, this.description, this.url});

  factory Source.fromJson(Map<String, dynamic> json){
    return Source(
        id: json['id'],
        name: json['name']
    );
  }

  factory Source.fromFullJson(Map<String, dynamic> json){
    return Source.fullSource(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        url: json['url']
    );
  }
}