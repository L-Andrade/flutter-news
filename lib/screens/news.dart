import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutternews/screens/sources.dart';

import '../main.dart';
import '../newsapi.dart';
import '../newsmodel.dart';
import 'article.dart';

import 'package:intl/intl.dart';

class NewsScreen extends StatelessWidget {
  String sourcesQuery;

  NewsScreen({this.sourcesQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('News'),
          actions: <Widget>[
            sourcesQuery == null
                ? IconButton(
                    icon: Icon(Icons.list),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SourcesScreen()));
                    },
                    tooltip: "Sources",
                  )
                : Container()
          ],
        ),
        body: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          HeadlinesCarousel(),
          Expanded(
              child: NewsArticlesScreen(
            sourcesQuery: sourcesQuery,
          ))
        ]));
  }
}

class NewsArticlesScreen extends StatefulWidget {
  final String sourcesQuery;

  NewsArticlesScreen({this.sourcesQuery});

  @override
  State<StatefulWidget> createState() {
    return NewsArticlesScreenState(sourcesQuery);
  }
}

class NewsArticlesScreenState extends State<NewsArticlesScreen> {
  NewsAPI _newsAPI;
  List<Article> _news;
  ScrollController _scrollController;
  int _page = 1;
  TextEditingController _textController;
  String sourcesQuery;

  NewsArticlesScreenState(this.sourcesQuery);

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
    return FutureBuilder(
      future: sourcesQuery == null
          ? _newsAPI.loadNewsByPage(_page)
          : _newsAPI.loadNewsByPageAndSource(_page, sourcesQuery),
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
    );
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

  _buildErrorRetry(String err) {
    return buildErrorRetry(err, () {
      _resetNews();
    });
  }
}

class HeadlinesCarousel extends StatelessWidget {
  final NewsAPI _newsAPI = NewsAPI();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _newsAPI.loadHeadlines(1),
      builder: (context, snapshot) {
        var headlines = <Article>[];
        if (snapshot.data != null &&
            snapshot.connectionState == ConnectionState.done) {
          headlines = (snapshot.data);
        }
        return headlines != null && headlines.isNotEmpty
            ? Column(
                children: <Widget>[
                  Container(
                      height: 100,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: headlines.length,
                          itemBuilder: (_, int index) {
                            return ArticleHeadline(headlines[index]);
                          })),
                  Divider(
                    height: 1.0,
                  ),
                  snapshot.hasError
                      ? Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(snapshot.error.toString()))
                      : Container(),
                ],
              )
            : snapshot.hasError
                ? Text(snapshot.error
                    .toString()) //_buildErrorRetry(snapshot.error.toString())
                : Center(
                    child: CircularProgressIndicator(),
                  );
      },
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
          navigateToArticle(context, article);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildImageOrError(article.imageUrl, 100, 80),
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

class ArticleHeadline extends StatelessWidget {
  final Article _article;

  ArticleHeadline(this._article);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          navigateToArticle(context, _article);
        },
        child: Stack(
          children: <Widget>[
            buildImageOrError(_article.imageUrl, 148, 84, withOpacity: true),
            Container(
                width: 148,
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.bottomCenter,
                child: Text(
                  _article.title,
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ))
          ],
        ),
      ),
    );
  }
}

navigateToArticle(BuildContext context, Article article) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => ArticleScreen(article)));
}

buildImage(String imageUrl, double width, double height,
    {bool withOpacity = false}) {
  return Stack(
    children: <Widget>[
      CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => Center(
            child: Container(
          child: Container(
            child: CircularProgressIndicator(),
            padding: EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
          ),
        )),
        errorWidget: (context, url, error) => Container(
          child: buildErrorIcon(),
          height: height,
        ),
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
      withOpacity
          ? Container(
              color: Colors.black.withOpacity(0.7),
              width: width,
              height: height,
            )
          : Container()
    ],
  );
}

buildImageOrError(String imageUrl, double width, double height,
    {bool withOpacity = false}) {
  return imageUrl != null
      ? buildImage(imageUrl, width, height, withOpacity: withOpacity)
      : Container(
          child: buildErrorIcon(),
          height: height,
        );
}
