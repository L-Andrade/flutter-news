import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../newsapi.dart';
import '../newsmodel.dart';
import 'article.dart';

import 'package:intl/intl.dart';

class NewsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewsScreenState();
  }
}

class NewsScreenState extends State<NewsScreen> {
  NewsAPI _newsAPI;
  List<Article> _news;
  ScrollController _scrollController;
  int _page = 1;
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _news = <Article>[];
    _newsAPI = NewsAPI();
    _textController = TextEditingController(text: _newsAPI.query);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        print("Increment page");
        setState(() {
          _page++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('News'),
        ),
        body: FutureBuilder(
          future: _newsAPI.loadNewsByPage(_page),
          builder: (context, snapshot) {
            if (snapshot.data != null &&
                snapshot.connectionState == ConnectionState.done) {
              print("Adding to article list...");
              _news.addAll(snapshot.data);
            }
            return _news != null && _news.isNotEmpty
                ? Column(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(top: 4.0),
                        child: RefreshIndicator(
                          child: ListView.separated(

                            controller: _scrollController,
                            itemBuilder: (_, int index) {
                              return ArticleCard(_news[index]);
                            },
                            itemCount: _news.length,
                            separatorBuilder: (BuildContext context, int index) {
                              if (index % 5 == 0) {
                                return Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(8.0),
                                        child: Text("Advertising")),
                                  ],
                                );
                              }
                              return Container(padding: EdgeInsets.symmetric(vertical: 4.0),);
                            },
                          ), onRefresh: _handleRefresh,
                        ),
                      )),
                      Divider(
                        height: 1.0,
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: TextField(
                                  controller: _textController,
                                  autofocus: false,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                  child: IconButton(
                                    icon: Icon(Icons.search),
                                    onPressed: () {
                                      _submitQuery(_textController.text);
                                    },
                                  ))
                            ],
                          )),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ));
  }

  _submitQuery(String text) {
    if (text.length < 1) return;
    // _textController.clear();
    _newsAPI.setQuery(text);
    _resetNews();
  }

  void _resetNews() {
    setState(() {
      _page = 1;
      _news = <Article>[];
    });
  }

  Future<void> _handleRefresh() async {
    _newsAPI.resetPage();
    _resetNews();
    return null;
  }
}

class ArticleCard extends StatelessWidget {
  final Article article;

  ArticleCard(this.article);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
        // padding: EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ArticleScreen(article)));
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CachedNetworkImage(
                  imageUrl: article.imageUrl ?? "https://via.placeholder.com/100",
                  placeholder: (context, url) => Center(
                      child: Container(
                    child: CircularProgressIndicator(),
                  )),
                  errorWidget: (context, url, error) => Container(child: Icon(Icons.error), width: 100,),
                  width: 100,
                fit: BoxFit.fitWidth,
                ),
              Flexible(
                child: Container(
                    padding: EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          article.title,
                        ),
                        Text(DateFormat("yyyy-MM-dd").format(article.publishedAt),
                            style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.end,)
                      ],
                    )),
              ),
            ],
          ),
        ),
      );
  }
}
