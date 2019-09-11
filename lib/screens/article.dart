import 'package:flutter/material.dart';
import 'package:flutternews/main.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../newsmodel.dart';

class ArticleScreen extends StatelessWidget {
  final Article _article;

  ArticleScreen(this._article);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_article.title),
        ),
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _article.imageUrl != null
                    ? Expanded(
                        child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        // padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(
                          _article.imageUrl,
                          height: 200,
                        ),
                      ))
                    : Container(
                        child: buildErrorIcon(),
                        height: 200,
                      ),
              ],
            ),
            Card(
              margin: EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  _article.author == null
                      ? "Written for ${_article.source.name}"
                      : "Written by ${_article.author} from ${_article.source.name}.",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              child: Text(
                "${DateFormat("yyyy-MM-dd HH:mm").format(_article.publishedAt)}",
                style: TextStyle(fontSize: 12),
              ),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: Text(_article.description)),
            RaisedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Leaving News App"),
                          content: Text(
                              'Are you sure you want to visit "${_article.url}"?'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            RaisedButton(
                              child: Text("Yes"),
                              onPressed: () {
                                _launchUrl(_article.url);
                              },
                              textColor: Colors.white,
                            )
                          ],
                        );
                      });
                },
                child: Text("Continue reading at ${_article.source.name}"))
          ],
        ));
  }

  _launchUrl(String url) async {
    if (url == null) return;
    if (await canLaunch(url))
      await launch(url);
    else
      throw 'Could not launch $url';
  }
}
