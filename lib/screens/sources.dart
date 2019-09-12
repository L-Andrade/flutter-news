import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../newsapi.dart';
import '../newsmodel.dart';

class SourcesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SourcesScreenState();
  }
}

class SourcesScreenState extends State<SourcesScreen> {
  NewsAPI _newsAPI;
  List<Source> _sources;
  TextEditingController _textEditingController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _newsAPI = NewsAPI();
    _sources = <Source>[];
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sources'),
        ),
        body: FutureBuilder(
          future: _newsAPI.loadSources(),
          builder: (context, snapshot) {
            if (snapshot.data != null &&
                snapshot.connectionState == ConnectionState.done) {
              _sources.addAll(snapshot.data);
            }
            return _sources != null && _sources.isNotEmpty
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
                      buildSearchBar(_textEditingController, (String text) {
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

  _buildListView() {
    return Container(
      margin: EdgeInsets.only(top: 4.0),
      child: RefreshIndicator(
        child: ListView.separated(
          itemBuilder: (_, int index) {
            return SourceCard(_sources[index]);
          },
          itemCount: _sources.length,
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
    return Text(err);
  }

  resetSources(){
    setState(() {
      _sources = <Source>[];
    });
  }

  Future<void> _handleRefresh() {
    resetSources();
    return null;
  }

  _submitQuery(String text) {
      if (text.length < 1) return;
      resetSources();
      _newsAPI.setQuery(text);
  }
}

class SourceCard extends StatelessWidget {
  final Source _source;

  SourceCard(this._source);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Go to source articles
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(_source.name, style: TextStyle(fontSize: 20))),
              Text(
                _source.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
    );
  }
}
