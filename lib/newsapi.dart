
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'newsmodel.dart';

const String _url = "https://newsapi.org/v2/";
const String _apiKey = "88895c3180394ade9ac457599c5b8af2";
const String _sortBy = "sortBy=publishedAt";

class NewsAPI {
  int lastPage = -1;
  String query = "technology";
  String sourcesQuery = "";

  Future loadNewsByPage(int page) async {
    if (lastPage == page) return null;
    var get = _url + "everything?q=$query&apiKey=$_apiKey&page=${page.toString()}&$_sortBy&sources=$sourcesQuery";
    List<Article> list;
    try {
      http.Response response = await http.get(get, headers: {"Accept": "application/json"});
      print("${response.statusCode}: ${response.reasonPhrase}");
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var listJson = data["articles"] as List;
        list = listJson.map<Article>((json) => Article.fromJson(json)).toList();
        lastPage = page;
      } else {
        throw Exception();
      }
    } catch (ex){
      throw "Could not get articles from NewsAPI :(";
    }
    return list;
  }

  Future loadSources() async {
    var get = _url + "sources?apiKey=$_apiKey&category=$query";
    List<Source> list;
    try {
      http.Response response = await http.get(get, headers: {"Accept": "application/json"});
      print("${response.statusCode}: ${response.reasonPhrase}");
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var listJson = data["sources"] as List;
        list = listJson.map<Source>((json) => Source.fromFullJson(json)).toList();
      } else {
        throw Exception();
      }
    } catch (ex){
      throw "Could not get sources from NewsAPI :(";
    }
    return list;
  }

  setQuery(String text) {
    resetPage();
    query = text;
  }

  resetPage(){
    lastPage = -1;
  }

  loadNewsByPageAndSource(int page, String sourcesQuery) {
    this.sourcesQuery = sourcesQuery;
    return loadNewsByPage(page);
  }

}
