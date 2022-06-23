// Packages
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Models
import '../models/movie_model.dart';
// Data
import '../data/firestore_data_parser.dart';
import '../data/tmdb_data_parser.dart';
// Widgets
import '../widgets/review_widgets.dart';
import '../widgets/text_widgets.dart';
import '../widgets/rounded_image.dart';
import '../widgets/dialogs.dart';

class MovieModelProvider extends StatefulWidget {
  final User? user;
  final MovieElement movie;

  MovieModelProvider(this.user, this.movie);

  @override
  _MovieModelProviderState createState() => _MovieModelProviderState();
}

class _MovieModelProviderState extends State<MovieModelProvider> {
  late MovieModel model;

  @override
  void initState() {
    super.initState();
    //model = MovieModel(widget.user!, widget.movie);
    model = MovieModel(widget.movie);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MovieModel>(
      model: model,
      child: MoviePage(widget.movie.id),
    );
  }
}

class MoviePage extends StatefulWidget {
  final int movieId;

  MoviePage(this.movieId);

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('reviews')
        .where('movie_id', isEqualTo: widget.movieId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var _model = ScopedModel.of<MovieModel>(context, rebuildOnChange: true);

    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        backgroundColor: theme.canvasColor,
        elevation: 0,
        title: Text(
          '${_model.movie.title}',
          style: theme.textTheme.headline1,
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            offset: Offset(0, 15),
            icon: Icon(
              Icons.playlist_add,
              color: theme.iconTheme.color,
            ),
            tooltip: 'Add to list',
            onSelected: (val) => _model.insertMovieInList(
              movie: _model.movie,
              listId: val,
              //userId: _model.user.docId,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'seen',
                child: Text('Have seen'),
              ),
              PopupMenuItem<String>(
                value: 'tobeseen',
                child: Text('Want to see'),
              ),
              PopupMenuItem<String>(
                enabled: false,
                child: TextButton.icon(
                    icon: Icon(Icons.list),
                    label: Text('Other lists'),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => SelectListDialog(_model),
                      );
                    }),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            MovieInfo(),
            SizedBox(height: 30),
            TitleText('Reviews', color: theme.primaryColor),
            SizedBox(height: 10),
            StreamBuilder(
              stream: _stream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    if (snapshot.hasError)
                      return SubtitleText('${snapshot.error}');
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
                            movieId: doc['movie_id'],
                            movieTitle: doc['movie_title'],
                            movieBackdropPath: doc['movie_backdrop_path'],
                            edited: doc['edited'],
                            reviewId: doc.id,
                            //user: _model.user,
                            isUserPage: false,
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

class MovieInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _model = ScopedModel.of<MovieModel>(context, rebuildOnChange: true);
    String _voteAverage = _model.movie.voteCount == 0
        ? 'No ratings'
        : '${_model.movie.voteAverage} / 10';

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: _model.movie.posterPath == null
                  ? BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15))
                  : BoxDecoration(),
              height: 250,
              width: 170,
              child: _model.movie.posterPath == null
                  ? Center(child: BodyText('No poster found.'))
                  : Hero(
                      tag: '${_model.movie.id}',
                      child: RoundedImage(
                        path: _model.movie.posterPath ?? '',
                        height: 200,
                      ),
                    ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
              height: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BodyText('Average rating:'),
                  TextButton.icon(
                    onPressed: null,
                    icon: Icon(Icons.star),
                    label: Column(
                      children: <Widget>[
                        BodyText(
                          '$_voteAverage',
                          fontWeight: FontWeight.bold,
                        ),
                        CaptionText('${_model.movie.voteCount} votes'),
                      ],
                    ),
                  ),
                  ...[
                    BodyText(
                      'My rating:',
                      padding: EdgeInsets.only(top: 10),
                    ),
                    RateMovieButton(),
                    SizedBox(height: 10),
                    /*if (_model.user.movieRatings
                        .containsKey('${_model.movie.id}'))
                      TextButton(
                        onPressed: () =>
                            _model.user.reviewedMovies.contains(_model.movie.id)
                                ? showDialog<void>(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) => ReviewExistsAlert(),
                                  )
                                : showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => ReviewDialog(
                                      _model.movie,
                                      _model,
                                    ),
                                  ),
                        child: BodyText('Write review'),
                      ),*/
                  ]
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TitleText(
              'Description',
              padding: EdgeInsets.only(left: 20, top: 20),
            ),
            SizedBox(height: 5),
            _model.movie.overview.isEmpty
                ? BodyText(
                    'Unfortunately we couldn\'t find a '
                    'description for this movie.',
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    overflow: TextOverflow.visible,
                  )
                : BodyText(
                    '${_model.movie.overview}',
                    overflow: TextOverflow.visible,
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          children: <Widget>[
            if (_model.movie.releaseDate.isNotEmpty)
              Chip(
                label: BodyText('${_model.movie.releaseDate}'),
              ),
            for (var f in _model.movie.genreIds)
              if (genres.containsKey(f)) Chip(label: BodyText('${genres[f]}'))
          ],
        ),
      ],
    );
  }
}

class RateMovieButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _model = ScopedModel.of<MovieModel>(context, rebuildOnChange: true);
    //var _currentRating = _model.user.movieRatings[_model.movie.id.toString()];

    return TextButton.icon(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        builder: (context) => RateSliderModalSheet(
          _model,
          5.0,
          //_currentRating ?? 5.0,
        ),
      ),
      icon: Icon(Icons.star),
      label: Column(
        children: <Widget>[
          BodyText('No rating', fontWeight: FontWeight.bold),
          CaptionText('Tap to rate'),
          /*if (_model.user.movieRatings.containsKey('${_model.movie.id}')) ...[
            BodyText(
              '$_currentRating / 10',
              fontWeight: FontWeight.bold,
            ),
            CaptionText('Tap to redo'),
          ] else ...[
            BodyText('No rating', fontWeight: FontWeight.bold),
            CaptionText('Tap to rate'),
          ]*/
        ],
      ),
    );
  }
}

class RateSliderModalSheet extends StatefulWidget {
  final MovieModel _model;
  final num initialVal;

  RateSliderModalSheet(this._model, this.initialVal) {
    /*if (!_model.user.movieRatings.containsKey('${_model.movie.id}'))
      _model.rateMovie(
        userId: _model.user.docId,
        guestId: _model.user.tmdbGuestId,
        rating: 5.0,
        movieId: _model.movie.id,
      );*/
  }

  @override
  _RateSliderModalSheetState createState() =>
      _RateSliderModalSheetState(initialVal);
}

class _RateSliderModalSheetState extends State<RateSliderModalSheet> {
  var _sliderValue;

  _RateSliderModalSheetState(this._sliderValue);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 230,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Slider(
                min: 0.0,
                max: 10.0,
                divisions: 20,
                label: _sliderValue.toStringAsFixed(1),
                onChanged: (doo) => setState(() => _sliderValue = doo),
                onChangeEnd: (doo) => widget._model.rateMovie(
                    //userId: widget._model.user.docId,
                    //guestId: widget._model.user.tmdbGuestId,
                    rating: double.parse(doo.toStringAsFixed(1)),
                    movieId: widget._model.movie.id),
                value: _sliderValue,
              ),
              BodyText('Drag slider to rate the movie on a scale from 1 to 10'),
              CaptionText('Tap anywhere else to dismiss',
                  padding: EdgeInsets.only(bottom: 20)),
              SubtitleText(
                  'Current rating: ${_sliderValue.toStringAsFixed(1)}'),
              CaptionText(
                'It might take a while for your rating to update in the system, please be patient',
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
