// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutternews/screens/news.dart';

void main() => runApp(NewsApp());

class NewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      title: 'News',
      home: NewsScreen(),
    );
  }
}

buildErrorIcon() {
  return Container(
    child: Icon(Icons.error),
    width: 100,
  );
}

buildSearchBar(
    TextEditingController textController, Null Function(String text) callback) {
  return Container(
    margin: EdgeInsets.all(4.0),
    child: Material(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: textController,
                autofocus: false,
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    callback(textController.text);
                  },
                ))
          ],
        )),
  );
}

buildErrorRetry(String err, Null Function() callback) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(err),
        RaisedButton(
          onPressed: () {
            callback();
          },
          child: Text("Retry"),
        ),
      ],
    ),
  );
}
