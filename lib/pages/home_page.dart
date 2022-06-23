// Packages
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:scoped_model/scoped_model.dart';
// Models
import '../models/home_model.dart';
// Data
import '../data/tmdb_data_parser.dart';
import '../data/firestore_data_parser.dart';
// Screens
import 'movie_page.dart';
import 'user_page.dart';
import 'login_page.dart';
// Widgets
import '../widgets/text_widgets.dart';
import '../widgets/dialogs.dart';
import '../widgets/rounded_image.dart';

class HomeModelProvider extends StatefulWidget {
  final User? user;

  HomeModelProvider(this.user);

  @override
  _HomeModelProviderState createState() => _HomeModelProviderState();
}

class _HomeModelProviderState extends State<HomeModelProvider> {
  late HomeModel model;

  @override
  void initState() {
    super.initState();
    model = HomeModel(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<HomeModel>(
      model: model,
      child: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var model = ScopedModel.of<HomeModel>(context, rebuildOnChange: true);

    return WillPopScope(
      onWillPop: () async => _willPopAction(context) as bool,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Platform.isAndroid
              ? null
              : IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.white),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginModelProvider(),
                      ),
                      (route) => false),
                ),
          backgroundColor: theme.canvasColor,
          elevation: 0,
          title: HomeAppBarTitle(model),
          actions: <Widget>[
            if (!model.searching) ...[
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: theme.iconTheme.color,
                ),
                onPressed: () => model.setSearching(true),
              ),
              PopupMenuButton<int>(
                offset: Offset(0, 15),
                icon: Icon(
                  Icons.sort,
                  color: theme.iconTheme.color,
                ),
                onSelected: (val) => model.presets(id: val),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('Popular now'),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Text('Top rated'),
                  ),
                  PopupMenuItem<int>(
                    value: 3,
                    child: Text('Upcoming'),
                  ),
                  PopupMenuItem<int>(
                    enabled: false,
                    child: TextButton.icon(
                        icon: Icon(Icons.more_vert),
                        label: Text('More options'),
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              var _filterBackup = model.backupFilters();
                              return ScopedModel<HomeModel>(
                                  model: model,
                                  child: FilterDialog(_filterBackup));
                            },
                          );
                        }),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: theme.iconTheme.color,
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserModelProvider(model.user!),
                    )),
              ),
            ],
          ],
        ),
        body: ScopedModelDescendant<HomeModel>(
          builder: (context, _, model) => PagewiseGridView.count(
            pageLoadController: model.pagewiseController,
            crossAxisCount: 2,
            mainAxisSpacing: 8.0,
            padding: EdgeInsets.all(15.0),
            itemBuilder: (context, MovieElement entry, index) {
              return HomePageMovieItem(entry);
            },
            noItemsFoundBuilder: (context) {
              return Center(child: TitleText('No results found...'));
            },
          ),
        ),
      ),
    );
  }

  Future<bool?> _willPopAction(BuildContext context) async {
    var model = ScopedModel.of<HomeModel>(context, rebuildOnChange: false);

    if (model.moviesShowing.substring(0, 7) == 'Results') {
      return model.backIfSearching();
    } else if (model.searching) {
      model.setSearching(false);
      return false;
    } else if (model.user != null) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: TitleText('Logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.cancel),
              label: SubtitleText('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton.icon(
              icon: Icon(Icons.check_circle),
              label: SubtitleText('Log out'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginModelProvider(),
                    ),
                    (route) => false);
              },
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: TitleText('Quit?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.cancel),
              label: SubtitleText('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton.icon(
              icon: Icon(Icons.check_circle),
              label: SubtitleText('Quit'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
    }
  }
}

class HomeAppBarTitle extends StatelessWidget {
  final HomeModel model;

  HomeAppBarTitle(this.model);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (model.searching)
      return _SearchField(model);
    else {
      return Row(
        children: <Widget>[
          Flexible(child: TitleText('${model.moviesShowing}')),
          model.orderIcon != null
              ? Icon(model.orderIcon, color: theme.iconTheme.color)
              : Container(),
        ],
      );
    }
  }
}

class _SearchField extends StatefulWidget {
  final HomeModel model;

  _SearchField(this.model);

  @override
  __SearchFieldState createState() => __SearchFieldState();
}

class __SearchFieldState extends State<_SearchField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    widget.model.setSearching(false);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return TextField(
      autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: (query) => (query != '')
          ? widget.model.search(query)
          : widget.model.setSearching(false),
      decoration: InputDecoration(
        filled: false,
        contentPadding: EdgeInsets.all(10),
        border: InputBorder.none,
        hintText: 'Search movies...',
        icon: IconButton(
          onPressed: () => widget.model.setSearching(false),
          icon: Icon(
            Icons.close,
            color: theme.iconTheme.color,
          ),
        ),
      ),
    );
  }
}

class HomePageMovieItem extends StatelessWidget {
  final MovieElement movie;

  HomePageMovieItem(this.movie);

  @override
  Widget build(BuildContext context) {
    var model = ScopedModel.of<HomeModel>(context, rebuildOnChange: false);

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieModelProvider(model.user, movie),
          )),
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (movie.posterPath == null)
              Container(
                width: 120,
                child: SubtitleText(
                  '${movie.title}',
                  textAlign: TextAlign.center,
                ),
              )
            else
              Hero(
                  tag: '${movie.id}',
                  child: RoundedImage(
                    path: movie.posterPath ?? '',
                    height: 200,
                  )),
          ],
        ),
      ),
    );
  }
}
