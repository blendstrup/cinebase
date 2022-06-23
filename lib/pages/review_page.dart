// Packages
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Models
import '../models/review_model.dart';
// Data
import '../data/firestore_data_parser.dart';
// Widgets
import '../widgets/review_widgets.dart';
import '../widgets/text_widgets.dart';
import '../widgets/dialogs.dart';

class ReviewModelProvider extends StatefulWidget {
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final int movieId;
  final String movieTitle;
  final String movieBackdropPath;
  final String reviewId;
  final num rating;
  final DateTime date;
  final bool edited;
  final User? user;

  ReviewModelProvider({
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.movieId,
    required this.movieTitle,
    required this.movieBackdropPath,
    required this.reviewId,
    required this.date,
    required this.rating,
    required this.user,
    required this.edited,
  });

  @override
  _ReviewModelProviderState createState() => _ReviewModelProviderState();
}

class _ReviewModelProviderState extends State<ReviewModelProvider> {
  late ReviewModel model;

  @override
  void initState() {
    super.initState();
    model = ReviewModel(
      authorId: widget.authorId,
      authorName: widget.authorName,
      movieId: widget.movieId,
      movieTitle: widget.movieTitle,
      movieBackdropPath: widget.movieBackdropPath,
      reviewId: widget.reviewId,
      title: widget.title,
      content: widget.content,
      date: widget.date,
      rating: widget.rating,
      user: widget.user!,
      edited: widget.edited,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ReviewModel>(
      model: model,
      child: ReviewPage(widget.reviewId),
    );
  }
}

class ReviewPage extends StatefulWidget {
  final String reviewId;

  ReviewPage(this.reviewId);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Stream<QuerySnapshot> _stream;

  FocusNode _focus = FocusNode();
  late TextEditingController _controller;

  bool showCommentButtons = false;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('reviews/${widget.reviewId}/comments')
        .snapshots();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var _model = ScopedModel.of<ReviewModel>(context, rebuildOnChange: true);
    var userId = _model.user.docId;
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.canvasColor,
        elevation: 0,
        title: TitleText('Review of ${_model.movieTitle}'),
        leading: BackButton(color: theme.iconTheme.color),
        actions: <Widget>[
          if (_model.authorId == userId)
            IconButton(
              icon: Icon(Icons.edit, color: theme.iconTheme.color),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => EditReviewDialog(_model),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            FullReview(),
            Center(
              child: TitleText(
                'Comments',
                color: theme.primaryColor,
                padding: EdgeInsets.only(bottom: 10),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                  filled: true,
                  labelText: 'Write comment',
                ),
              ),
            ),
            if (_focus.hasFocus || _controller.text.isNotEmpty)
              ButtonBar(
                children: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.cancel),
                    label: SubtitleText('Cancel'),
                    onPressed: () {
                      _controller.text = '';
                      _focus.unfocus();
                      setState(() {
                        showCommentButtons = false;
                      });
                    },
                  ),
                  TextButton.icon(
                      icon: Icon(Icons.check_circle),
                      label: SubtitleText('Submit'),
                      onPressed: () {
                        _model.commentOnReview(
                          authorId: _model.user.docId,
                          authorName: _model.user.name,
                          content: _controller.text,
                          reviewId: widget.reviewId,
                        );
                        _controller.clear();
                        _focus.unfocus();
                      }),
                ],
              ),
            SizedBox(height: 10),
            StreamBuilder(
              stream: _stream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    if (snapshot.hasError)
                      return SubtitleText('${snapshot.error}');
                    if (snapshot.data!.docs.isEmpty)
                      return SubtitleText('No comments found');
                    return ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: <Widget>[
                        for (var doc in snapshot.data!.docs)
                          Comment(
                            authorId: doc['author_id'],
                            authorName: doc['author_name'],
                            content: doc['content'],
                            date: doc['date'].toDate(),
                            commentId: doc.id,
                            reviewId: _model.reviewId,
                          ),
                      ],
                    );
                }
              },
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
