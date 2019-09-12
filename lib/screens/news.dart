import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutternews/screens/sources.dart';

import '../main.dart';
import '../newsapi.dart';
import '../newsmodel.dart';
import 'article.dart';

import 'package:intl/intl.dart';

class NewsScreen extends StatefulWidget {
  final String sourcesQuery;

  NewsScreen({this.sourcesQuery});

  @override
  State<StatefulWidget> createState() {
    return NewsScreenState(sourcesQuery);
  }
}

class NewsScreenState extends State<NewsScreen> {
  NewsAPI _newsAPI;
  List<Article> _news;
  ScrollController _scrollController;
  int _page = 1;
  TextEditingController _textController;
  String sourcesQuery;


  NewsScreenState(this.sourcesQuery);

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
          actions: <Widget>[
            IconButton(icon: Icon(Icons.list), onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SourcesScreen()));
            }, tooltip: "Sources",)
          ],
        ),
        body: FutureBuilder(
          future: sourcesQuery == null ? _newsAPI.loadNewsByPage(_page) : _newsAPI.loadNewsByPageAndSource(_page, sourcesQuery),
          builder: (context, snapshot) {
            if (snapshot.data != null &&
                snapshot.connectionState == ConnectionState.done) {
              _news.addAll(snapshot.data);
            }
            return _news != null && _news.isNotEmpty
                ? Column(
                    children: <Widget>[
                      Expanded(child: _buildListView()),
                      Divider(
                        height: 1.0,
                      ),
                      snapshot.hasError
                          ? Container(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(snapshot.error.toString()))
                          : Container(),
                      buildSearchBar(_textController, (String text) {
                        _submitQuery(text);
                      }),
                    ],
                  )
                : snapshot.hasError
                    ? _buildErrorRetry(snapshot.error.toString())
                    : Center(
                        child: CircularProgressIndicator(),
                      );
          },
        ));
  }

  _submitQuery(String text) {
    if (text.length < 1) return;
    // _textController.clear()
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

  _buildListView() {
    return Container(
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
                      padding: EdgeInsets.all(8.0), child: Text("Advertising")),
                ],
              );
            }
            return Container(
              padding: EdgeInsets.symmetric(vertical: 4.0),
            );
          },
        ),
        onRefresh: _handleRefresh,
      ),
    );
  }


  _buildErrorRetry(String error) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(error),
          RaisedButton(
            onPressed: () {
              _resetNews();
            },
            child: Text("Retry"),
          ),
        ],
      ),
    );
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
            article.imageUrl != null ?
            CachedNetworkImage(
              imageUrl: article.imageUrl,
              placeholder: (context, url) => Center(
                  child: Container(
                child: Container(
                  child: CircularProgressIndicator(),
                  padding: EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
                ),
              )),
              errorWidget: (context, url, error) => Container(child: buildErrorIcon(), height: 80,),
              width: 100,
              height: 80,
              fit: BoxFit.cover,
            ) : Container(child: buildErrorIcon(), height: 80,),
            Flexible(
              child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat("yyyy-MM-dd").format(article.publishedAt),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.end,
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
