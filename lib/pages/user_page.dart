// Packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Models
import '../models/user_model.dart';
// Data
import '../data/firestore_data_parser.dart';
import '../data/tmdb_data_parser.dart';
// Screens
import 'movie_page.dart';
// Widgets
import '../widgets/text_widgets.dart';
import '../widgets/review_widgets.dart';
import '../widgets/list_widgets.dart';
import '../widgets/dialogs.dart';
import '../widgets/rounded_image.dart';

class UserModelProvider extends StatefulWidget {
  final User user;
  final bool isUserOwner;

  UserModelProvider(this.user, {this.isUserOwner: true});

  @override
  _UserModelProviderState createState() => _UserModelProviderState();
}

class _UserModelProviderState extends State<UserModelProvider> {
  late UserModel model;

  @override
  void initState() {
    super.initState();
    model = UserModel(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model: model,
      child: UserPage(widget.isUserOwner),
    );
  }
}

class UserPage extends StatefulWidget {
  final bool isUserOwner;

  UserPage(this.isUserOwner);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _page = 0;
  late PageController _pageController;

  var navigationItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      label: 'Review History',
      icon: Icon(Icons.history),
    ),
    BottomNavigationBarItem(
      label: 'Movie Lists',
      icon: Icon(Icons.list),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _page);
  }

  @override
  Widget build(BuildContext context) {
    var _model = ScopedModel.of<UserModel>(context, rebuildOnChange: true);
    ThemeData theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => _willPopAction(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.canvasColor,
          elevation: 0,
          title: TitleText('Profile: ${_model.user.name}'),
          leading: BackButton(color: theme.iconTheme.color),
          actions: <Widget>[
            if (widget.isUserOwner)
              IconButton(
                icon: Icon(Icons.edit, color: theme.iconTheme.color),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => EditUserDialog(_model),
                  );
                },
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _page,
          onTap: (index) {
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 300), curve: Curves.easeIn);

            if (navigationItems.length == 3) if (index == 0 || index == 1)
              navigationItems.removeAt(2);
          },
          items: List.of(navigationItems),
        ),
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (newPage) {
            setState(() {
              _page = newPage;
            });
          },
          children: <Widget>[
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  UserInfo(model: _model, isUserOwner: widget.isUserOwner),
                  ReviewHistory(_model, widget.isUserOwner),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  UserInfo(model: _model, isUserOwner: widget.isUserOwner),
                  AllUserLists(
                    model: _model,
                    isUserOwner: widget.isUserOwner,
                    parent: this,
                  ),
                ],
              ),
            ),
            if (navigationItems.length > 2)
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    UserInfo(model: _model, isUserOwner: widget.isUserOwner),
                    SingleUserList(
                      title: _model.currentListTitle,
                      listId: _model.currentListId,
                      model: _model,
                      isUserOwner: widget.isUserOwner,
                      private: _model.currentListPrivate,
                      parent: this,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _willPopAction() async {
    if (navigationItems.length == 3 || _page == 2) {
      navigationItems.removeAt(2);

      _pageController.animateToPage(1,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);

      return false;
    } else {
      return true;
    }
  }
}

class UserInfo extends StatelessWidget {
  final UserModel model;
  final bool isUserOwner;

  UserInfo({required this.model, required this.isUserOwner});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 50,
              child: TitleText(
                '${model.user.name.substring(0, 1)}'.toUpperCase(),
                color: Colors.white70,
                fontSize: 50,
              ),
            ),
            SizedBox(height: 10),
            TitleText('${model.user.name}'),
            if (isUserOwner) CaptionText('${model.user.email}'),
          ],
        ),
        SubtitleText(
          'Description',
          padding: EdgeInsets.only(bottom: 5, top: 25),
        ),
        BodyText(
          '${model.user.description}',
          overflow: TextOverflow.visible,
        ),
        Divider(height: 30),
      ],
    );
  }
}

class AllUserLists extends StatefulWidget {
  final UserModel model;
  final bool isUserOwner;
  final _UserPageState parent;

  AllUserLists({
    required this.model,
    required this.isUserOwner,
    required this.parent,
  });

  @override
  _AllUserListsState createState() => _AllUserListsState();
}

class _AllUserListsState extends State<AllUserLists> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('users/${widget.model.user.docId}/lists')
        .orderBy('date')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var parent = widget.parent;

    return Column(
      children: <Widget>[
        if (widget.isUserOwner)
          ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => CreateListDialog(widget.model),
            ),
            child: SubtitleText('Create new list'),
          ),
        SizedBox(height: 20),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return CircularProgressIndicator();
              default:
                if (snapshot.hasError) return SubtitleText('${snapshot.error}');
                if (!snapshot.hasData) return SubtitleText('No lists found');
                return GridView.count(
                  crossAxisCount: 2,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.68,
                  shrinkWrap: true,
                  children: <Widget>[
                    if (snapshot.data != null)
                      for (var doc in snapshot.data!.docs)
                        if (widget.isUserOwner ||
                            (!widget.isUserOwner && !doc['private']))
                          if (doc['three_posters'].length >= 3)
                            TripleListItem(
                              path1: doc['three_posters'][0],
                              path2: doc['three_posters'][1],
                              path3: doc['three_posters'][2],
                              title: doc['title'],
                              listId: doc.id,
                              onTap: () => navigateToList(parent, doc),
                            )
                          else if (doc['three_posters'].length == 2)
                            DoubleListItem(
                              path1: doc['three_posters'][0],
                              path2: doc['three_posters'][1],
                              title: doc['title'],
                              listId: doc.id,
                              onTap: () => navigateToList(parent, doc),
                            )
                          else if (doc['three_posters'].length == 1)
                            SingleListItem(
                              path: doc['three_posters'][0],
                              title: doc['title'],
                              listId: doc.id,
                              onTap: () => navigateToList(parent, doc),
                            )
                          else
                            BlankListItem(
                              title: doc['title'],
                              listId: doc.id,
                              onTap: () => navigateToList(parent, doc),
                            ),
                  ],
                );
            }
          },
        ),
      ],
    );
  }

  void navigateToList(_UserPageState parent, DocumentSnapshot doc) {
    if (parent.navigationItems.length < 3) {
      parent.setState(() {
        parent.navigationItems.add(
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: doc['title'],
          ),
        );
        widget.model.updateCurrentList(
          currentListId: doc.id,
          currentListTitle: doc['title'],
          currentListPrivate: doc['private'],
        );
        parent._pageController.animateToPage(2,
            duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      });
    }
  }
}

class SingleUserList extends StatefulWidget {
  final String title;
  final String listId;
  final UserModel model;
  final bool isUserOwner;
  final bool private;
  final _UserPageState parent;

  SingleUserList({
    required this.title,
    required this.listId,
    required this.model,
    required this.isUserOwner,
    required this.private,
    required this.parent,
  });

  @override
  _SingleUserListState createState() => _SingleUserListState();
}

class _SingleUserListState extends State<SingleUserList> {
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('users/${widget.model.user.docId}/lists'
            '/${widget.listId}/movies')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (widget.isUserOwner && widget.private) ...[
          TitleText(
            widget.title,
            padding: EdgeInsets.only(top: 10),
          ),
          BodyText(
            '(Private)',
            padding: EdgeInsets.only(bottom: 10),
          ),
        ] else
          TitleText(
            widget.title,
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
        if (widget.isUserOwner &&
            widget.listId != 'seen' &&
            widget.listId != 'tobeseen')
          ElevatedButton(
            onPressed: () async {
              bool? result = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => EditListDialog(
                  model: widget.model,
                  title: widget.title,
                  private: widget.private,
                  listId: widget.listId,
                ),
              );
              if (result != null) {
                widget.parent._pageController.animateToPage(1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
                widget.parent.navigationItems.removeAt(2);
              }
            },
            child: SubtitleText('Edit list'),
          ),
        StreamBuilder(
          stream: _stream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return CircularProgressIndicator();
              default:
                if (snapshot.hasError) return SubtitleText('${snapshot.error}');
                if (snapshot.data!.docs.isEmpty)
                  return SubtitleText(
                    'No movies found',
                    padding: EdgeInsets.symmetric(vertical: 10),
                  );
                return GridView.count(
                  crossAxisCount: 2,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.all(15.0),
                  shrinkWrap: true,
                  children: <Widget>[
                    for (var doc in snapshot.data!.docs)
                      MovieItem(
                        MovieElement.fromFirestore(doc),
                        widget.isUserOwner,
                      ),
                  ],
                );
            }
          },
        ),
        if (widget.isUserOwner)
          CaptionText(
            'Long press a movie to remove it',
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
      ],
    );
  }
}

class MovieItem extends StatelessWidget {
  final MovieElement movie;
  final bool isUserOwner;

  MovieItem(this.movie, this.isUserOwner);

  @override
  Widget build(BuildContext context) {
    var model = ScopedModel.of<UserModel>(context, rebuildOnChange: false);
    var onLongPress = () => model.deleteMovieFromList(
          movie: movie,
          listId: model.currentListId,
          userId: model.user.docId,
        );

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieModelProvider(model.user, movie),
          )),
      onLongPress: isUserOwner ? onLongPress : null,
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
                    width: 0,
                    height: 0,
                  )),
          ],
        ),
      ),
    );
  }
}
