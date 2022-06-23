// Packages
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
// Models
import '../models/review_model.dart';
import '../models/user_model.dart';
// Data
import '../data/firestore_data_parser.dart';
// Screens
import '../pages/review_page.dart';
import '../pages/user_page.dart';
// Widgets
import 'rounded_image.dart';
import 'text_widgets.dart';

class FullReview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return ScopedModelDescendant<ReviewModel>(
      builder: (context, _, model) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: RoundedImage(
              path: model.movieBackdropPath,
              width: MediaQuery.of(context).size.width,
              height: 150,
            ),
          ),
          TitleText(
            model.title,
            padding: EdgeInsets.only(top: 20, bottom: 10),
          ),
          RichText(
            text: TextSpan(
              style: theme.textTheme.caption,
              children: <TextSpan>[
                TextSpan(text: 'Written by '),
                TextSpan(
                  text: model.authorName,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if (model.authorId != model.user.docId) {
                        User user = await model.fetchUserFromId(model.authorId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserModelProvider(
                              user,
                              isUserOwner: false,
                            ),
                          ),
                        );
                      }
                    },
                  style: theme.textTheme.caption?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
                TextSpan(text: ' on '),
                TextSpan(text: '${model.date}'.substring(0, 10)),
                if (model.edited)
                  TextSpan(text: ' (edited)', style: theme.textTheme.caption)
              ],
            ),
          ),
          BodyText(
            model.content,
            overflow: TextOverflow.visible,
            padding: EdgeInsets.only(top: 20),
          ),
          BodyText(
            'Rating: ${model.rating}',
            fontWeight: FontWeight.bold,
            padding: EdgeInsets.only(top: 20, bottom: 20),
          ),
        ],
      ),
    );
  }
}

class ShortReview extends StatelessWidget {
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
  final bool isUserPage;
  final bool edited;
  final User? user;

  ShortReview({
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
    this.user,
    required this.edited,
    required this.isUserPage,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      width: 400,
      padding: const EdgeInsets.only(bottom: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewModelProvider(
                  authorId: authorId,
                  authorName: authorName,
                  movieId: movieId,
                  movieTitle: movieTitle,
                  movieBackdropPath: movieBackdropPath,
                  reviewId: reviewId,
                  title: title,
                  content: content,
                  date: date,
                  rating: rating,
                  user: user,
                  edited: edited,
                ),
              )),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (isUserPage)
                  CaptionText(
                    '$movieTitle',
                    padding: EdgeInsets.only(bottom: 5),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SubtitleText('$title'),
                          SizedBox(height: 5),
                          CaptionText('Written by: $authorName'),
                        ],
                      ),
                    ),
                    TitleText('$rating', color: theme.primaryColor)
                  ],
                ),
                SizedBox(height: 15),
                BodyText('$content'.replaceAll('\n', ' ').trim(), maxLines: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewHistory extends StatefulWidget {
  final UserModel _model;
  final bool isUserOwner;

  ReviewHistory(this._model, this.isUserOwner);

  @override
  _ReviewHistoryState createState() => _ReviewHistoryState();
}

class _ReviewHistoryState extends State<ReviewHistory> {
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('reviews')
        .where('author_id', isEqualTo: widget._model.user.docId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 15),
        StreamBuilder(
          stream: _stream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) return SubtitleText('${snapshot.error}');
                if (snapshot.data!.docs.isEmpty)
                  return SubtitleText('No reviews found');
                return ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                    for (var doc in snapshot.data!.docs)
                      ShortReview(
                        title: doc['title'],
                        content: doc['content'],
                        rating: doc['rating'],
                        date: doc['date'].toDate(),
                        authorId: doc['author_id'],
                        authorName: doc['author_name'],
                        reviewId: doc.id,
                        movieId: doc['movie_id'],
                        movieTitle: doc['movie_title'],
                        movieBackdropPath: doc['movie_backdrop_path'],
                        edited: doc['edited'],
                        user: widget.isUserOwner ? widget._model.user : null,
                        isUserPage: true,
                      ),
                  ],
                );
            }
          },
        ),
      ],
    );
  }
}

class Comment extends StatefulWidget {
  final String authorId;
  final String authorName;
  final DateTime date;
  final String content;
  final String commentId;
  final String reviewId;

  Comment({
    required this.authorId,
    required this.authorName,
    required this.date,
    required this.content,
    required this.commentId,
    required this.reviewId,
  });

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool showingReplies = false;
  bool replying = false;

  @override
  Widget build(BuildContext context) {
    final _model = ScopedModel.of<ReviewModel>(context, rebuildOnChange: false);
    final theme = Theme.of(context);
    var authorId = widget.authorId;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            dense: true,
            title: Row(
              children: <Widget>[
                ScopedModelDescendant<ReviewModel>(
                  builder: (context, _, model) => GestureDetector(
                    onTap: () async {
                      if (authorId != _model.user.docId) {
                        User user = await model.fetchUserFromId(authorId);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserModelProvider(
                                user,
                                isUserOwner: false,
                              ),
                            ));
                      }
                    },
                    child: authorId == _model.authorId
                        ? SubtitleText('${widget.authorName}')
                        : SubtitleText('${widget.authorName}'),
                  ),
                ),
                SizedBox(width: 10),
                CaptionText(
                  '${widget.date.toLocal()}'.substring(0, 10) +
                      ' at ' +
                      '${widget.date.toLocal()}'.substring(11, 16),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: BodyText('${widget.content}', maxLines: 5),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton.icon(
                //textColor: theme.textTheme.caption.color,
                icon: showingReplies
                    ? Icon(Icons.arrow_drop_up)
                    : Icon(Icons.arrow_drop_down),
                label: showingReplies
                    ? CaptionText('Hides replies')
                    : CaptionText('View replies'),
                onPressed: () =>
                    setState(() => showingReplies = !showingReplies),
              ),
              TextButton.icon(
                //textColor: theme.textTheme.caption.color,
                icon: replying ? Icon(Icons.clear) : Icon(Icons.add),
                label: replying ? CaptionText('Cancel') : CaptionText('Reply'),
                onPressed: () => setState(() => replying = !replying),
              ),
            ],
          ),
          if (replying) ...[
            Divider(),
            TextField(
              onSubmitted: (val) {
                _model.replyToComment(
                  authorId: _model.user.docId,
                  authorName: _model.user.name,
                  content: val,
                  reviewId: widget.reviewId,
                  commentId: widget.commentId,
                );
                setState(() => replying = false);
              },
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Write your reply...',
                labelStyle: theme.textTheme.caption?.copyWith(fontSize: 14),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
          if (showingReplies) ...[
            Divider(),
            Replies(
              reviewId: widget.reviewId,
              commentId: widget.commentId,
              commentAuthorId: widget.authorId,
            ),
          ],
        ],
      ),
    );
  }
}

class Replies extends StatefulWidget {
  final String reviewId;
  final String commentId;
  final String commentAuthorId;

  Replies({
    required this.reviewId,
    required this.commentId,
    required this.commentAuthorId,
  });

  @override
  _RepliesState createState() => _RepliesState();
}

class _RepliesState extends State<Replies> {
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('reviews/${widget.reviewId}/'
            'comments/${widget.commentId}/replies')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder(
      stream: _stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) return SubtitleText('${snapshot.error}');
            if (snapshot.data!.docs.isEmpty)
              return Center(
                child: CaptionText(
                  'No replies found...',
                  padding: EdgeInsets.only(bottom: 15, top: 5),
                ),
              );
            return ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                for (var doc in snapshot.data!.docs)
                  Reply(doc: doc, replies: widget, theme: theme),
                SizedBox(height: 10),
              ],
            );
        }
      },
    );
  }
}

class Reply extends StatelessWidget {
  final DocumentSnapshot doc;
  final Replies replies;
  final ThemeData theme;

  Reply({
    required this.doc,
    required this.replies,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final _model = ScopedModel.of<ReviewModel>(context, rebuildOnChange: false);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ScopedModelDescendant<ReviewModel>(
                  builder: (context, _, model) => GestureDetector(
                        onTap: () async {
                          if (doc['author_id'] != _model.user.docId) {
                            User user =
                                await model.fetchUserFromId(doc['author_id']);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserModelProvider(
                                    user,
                                    isUserOwner: false,
                                  ),
                                ));
                          }
                        },
                        child: doc['author_id'] == _model.authorId
                            ? SubtitleText(doc['author_name'])
                            : SubtitleText(doc['author_name']),
                      )),
              SizedBox(width: 10),
              CaptionText(
                '${doc['date'].toDate()}'.substring(0, 10) +
                    ' at ' +
                    '${doc['date'].toDate()}'.substring(11, 16),
                maxLines: 1,
              ),
            ],
          ),
          BodyText(
            doc['content'],
            overflow: TextOverflow.visible,
            padding: EdgeInsets.symmetric(vertical: 5),
          ),
          Divider(),
        ],
      ),
    );
  }
}
