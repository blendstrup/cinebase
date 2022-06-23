// Packages
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Models
import '../models/home_model.dart';
import '../models/movie_model.dart';
import '../models/review_model.dart';
import '../models/login_model.dart';
import '../models/user_model.dart';
// Data
import '../data/tmdb_data_parser.dart';
// Screens
import '../pages/login_page.dart';
// Widgets
import 'text_widgets.dart';

class CreateUserDialog extends StatefulWidget {
  @override
  _CreateUserDialogState createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _createUserFormKey = GlobalKey<FormState>();

  final _signupNameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPasswordCtrl = TextEditingController();

  final _signupEmailNode = FocusNode();
  final _signupPasswordNode = FocusNode();

  bool _validatingInput = false;
  bool _emailExists = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: TitleText('Create Cinebase user'),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 19),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20, width: 500),
              Form(
                key: _createUserFormKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      maxLength: 50,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Enter your name';
                        } else {
                          return '';
                        }
                      },
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                      controller: _signupNameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onFieldSubmitted: (val) {
                        FocusScope.of(context).requestFocus(_signupEmailNode);
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      validator: (val) {
                        if (val!.isEmpty ||
                            !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val)) {
                          return 'Enter a valid e-mail';
                        } else if (_emailExists) {
                          return 'E-mail already exists';
                        } else {
                          return '';
                        }
                      },
                      focusNode: _signupEmailNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      controller: _signupEmailCtrl,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onFieldSubmitted: (val) {
                        FocusScope.of(context)
                            .requestFocus(_signupPasswordNode);
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Enter a password';
                        } else {
                          return '';
                        }
                      },
                      focusNode: _signupPasswordNode,
                      obscureText: _obscurePassword,
                      controller: _signupPasswordCtrl,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: _obscurePassword
                              ? Icon(Icons.visibility_off)
                              : Icon(Icons.visibility),
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            if (_validatingInput)
              CircularProgressIndicator()
            else ...[
              Wrap(
                children: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.cancel),
                    label: SubtitleText('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.check_circle),
                    label: SubtitleText('Create user'),
                    onPressed: () async {
                      setState(() {
                        _validatingInput = true;
                      });

                      await ScopedModel.of<LoginModel>(context,
                              rebuildOnChange: false)
                          .validateUserCreation(_signupEmailCtrl.text)
                          .then((boo) => _emailExists = boo);

                      if (_createUserFormKey.currentState!.validate()) {
                        ScopedModel.of<LoginModel>(context,
                                rebuildOnChange: false)
                            .createNewUser(
                                email: _signupEmailCtrl.text,
                                name: _signupNameCtrl.text,
                                password: _signupPasswordCtrl.text);
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          _validatingInput = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FilterDialog extends StatelessWidget {
  final List _filterBackup;

  FilterDialog(this._filterBackup);

  @override
  Widget build(BuildContext context) {
    var _model = ScopedModel.of<HomeModel>(context, rebuildOnChange: true);

    return SingleChildScrollView(
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: TitleText('Filter options'),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubtitleText('Sort by', padding: EdgeInsets.only(top: 10)),
            _SortBy(model: _model),
            SubtitleText('In order', padding: EdgeInsets.only(top: 10)),
            _OrderBy(model: _model),
            SubtitleText(
              'Minimum amount of ratings',
              padding: EdgeInsets.only(top: 10),
            ),
            VoteCountMin(model: _model),
            SubtitleText(
              'Release dates',
              padding: EdgeInsets.only(top: 20, bottom: 10),
            ),
            _ReleaseDateOption(
              model: _model,
              prefix: 'From:',
              isMin: true,
            ),
            SizedBox(height: 10),
            _ReleaseDateOption(
              model: _model,
              prefix: 'To:',
              isMin: false,
            ),
            SubtitleText(
              'Genres',
              padding: EdgeInsets.only(top: 20, bottom: 10),
            ),
            _GenreFilterChips(model: _model),
          ],
        ),
        actions: <Widget>[
          Wrap(
            children: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.cancel),
                label: SubtitleText('Cancel'),
                onPressed: () {
                  _model.updateFilters(
                    orderBy: _filterBackup[0],
                    category: _filterBackup[1],
                    voteCountMin: _filterBackup[2],
                    releaseDateMin: _filterBackup[3],
                    releaseDateMax: _filterBackup[4],
                    genres: _filterBackup[5],
                  );
                  Navigator.of(context).pop();
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.check_circle),
                label: SubtitleText('Submit'),
                onPressed: () {
                  _model.refreshPagewiseController();
                  _model.updateHomePageTitle();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortBy extends StatelessWidget {
  final HomeModel model;

  _SortBy({required this.model});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: model.category,
        items: <DropdownMenuItem<String>>[
          DropdownMenuItem(
            value: 'popularity',
            child: BodyText('Popularity'),
          ),
          DropdownMenuItem(
            value: 'vote_average',
            child: BodyText('Rating'),
          ),
          DropdownMenuItem(
            value: 'primary_release_date',
            child: BodyText('Release date'),
          ),
        ],
        onChanged: (val) => model.updateFilters(category: val.toString()),
      ),
    );
  }
}

class _OrderBy extends StatelessWidget {
  final HomeModel model;

  _OrderBy({required this.model});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: model.orderBy,
        items: <DropdownMenuItem<String>>[
          DropdownMenuItem(
            value: 'desc',
            child: BodyText('Descending'),
          ),
          DropdownMenuItem(
            value: 'asc',
            child: BodyText('Ascending'),
          ),
        ],
        onChanged: (val) => model.updateFilters(orderBy: val.toString()),
      ),
    );
  }
}

class VoteCountMin extends StatefulWidget {
  final HomeModel model;

  VoteCountMin({required this.model});

  @override
  _VoteCountMinState createState() => _VoteCountMinState();
}

class _VoteCountMinState extends State<VoteCountMin> {
  final _voteCountTextController = TextEditingController();

  @override
  void dispose() {
    _voteCountTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: _voteCountTextController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: '${widget.model.voteCountMin}',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.only(left: 10),
          suffixIcon: IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.clear),
              onPressed: () {
                _voteCountTextController.text.length > 0
                    ? _voteCountTextController.clear()
                    : widget.model.updateFilters(voteCountMin: 0);
                FocusScope.of(context).requestFocus(FocusNode());
              }),
        ),
        onSubmitted: (val) {
          widget.model.updateFilters(voteCountMin: int.parse(val));
          _voteCountTextController.clear();
        },
      ),
    );
  }
}

class _GenreFilterChips extends StatelessWidget {
  final HomeModel model;

  _GenreFilterChips({required this.model});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      children: <Widget>[
        for (var i in genres.keys)
          FilterChip(
            selected: model.genres.contains('$i,'),
            label: Text('${genres[i]}'),
            disabledColor: Theme.of(context).disabledColor,
            selectedColor: Theme.of(context).primaryColor,
            onSelected: (boo) =>
                boo ? model.addGenre('$i,') : model.removeGenre('$i,'),
          ),
      ],
    );
  }
}

class _ReleaseDateOption extends StatelessWidget {
  final HomeModel model;
  final String prefix;
  final bool isMin;

  _ReleaseDateOption({
    required this.model,
    required this.prefix,
    required this.isMin,
  });

  @override
  Widget build(BuildContext context) {
    String _releaseDate = isMin ? model.releaseDateMin : model.releaseDateMax;

    return TextField(
      onTap: () => changeDate(context, _releaseDate),
      focusNode: _AlwaysDisabledFocusNode(),
      textAlign: TextAlign.end,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(10),
        icon: Container(width: 50, child: BodyText(prefix)),
        hintText: _releaseDate == '' ? 'Any' : _releaseDate,
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => isMin
              ? model.updateFilters(releaseDateMin: '')
              : model.updateFilters(releaseDateMax: ''),
        ),
      ),
    );
  }

  void changeDate(BuildContext context, String releaseDate) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.year,
      initialDate: DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      isMin
          ? model.updateFilters(
              releaseDateMin: date.toString().substring(0, 10))
          : model.updateFilters(
              releaseDateMax: date.toString().substring(0, 10));
    }
  }
}

class _AlwaysDisabledFocusNode extends FocusNode {
  bool get hasFocus => false;
}

class ReviewDialog extends StatefulWidget {
  final MovieElement movie;
  final MovieModel model;

  ReviewDialog(this.movie, this.model);

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _createReviewFormKey = GlobalKey<FormState>();

  final _writeContentNode = FocusNode();

  final _title = TextEditingController();
  final _review = TextEditingController();

  bool _containsSpoiler = false;

  @override
  void dispose() {
    _title.dispose();
    _review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: TitleText('Write review'),
          contentPadding: EdgeInsets.only(left: 24, right: 24, bottom: 10),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20, width: 500),
              Form(
                key: _createReviewFormKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      maxLength: 50,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Write a title for the review';
                        } else {
                          return '';
                        }
                      },
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _title,
                      decoration: InputDecoration(
                        labelText: 'Review Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onFieldSubmitted: (val) {
                        FocusScope.of(context).requestFocus(_writeContentNode);
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Write your review';
                        } else {
                          return '';
                        }
                      },
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      focusNode: _writeContentNode,
                      controller: _review,
                      decoration: InputDecoration(
                        labelText: 'Write your review here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        SubtitleText('Contains spoilers:'),
                        Checkbox(
                          value: _containsSpoiler,
                          onChanged: (boo) => setState(() {
                            _containsSpoiler = !_containsSpoiler;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Wrap(
              children: <Widget>[
                TextButton.icon(
                  icon: Icon(Icons.cancel),
                  label: SubtitleText('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton.icon(
                  icon: Icon(Icons.check_circle),
                  label: SubtitleText('Submit'),
                  onPressed: () {
                    if (_createReviewFormKey.currentState!.validate()) {
                      widget.model.createReview(
                        //authorId: widget.model.user.docId,
                        //authorName: widget.model.user.name,
                        containsSpoilers: _containsSpoiler,
                        content: _review.text,
                        movieId: widget.movie.id,
                        movieTitle: widget.movie.title,
                        movieBackdropPath: widget.movie.backdropPath ?? '',
                        //rating: widget.model.user
                        //        .movieRatings[widget.movie.id.toString()] ??
                        //    0,
                        title: _title.text,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewExistsAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: SubtitleText('You\'ve already written a review for this movie!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BodyText(
            'Please edit or delete your current review.',
            overflow: TextOverflow.visible,
          ),
          TextButton.icon(
            //color: Theme.of(context).accentColor,
            icon: Icon(Icons.check_circle),
            onPressed: () => Navigator.pop(context),
            label: SubtitleText('Understood'),
          ),
        ],
      ),
    );
  }
}

class EditReviewDialog extends StatefulWidget {
  final ReviewModel model;

  EditReviewDialog(this.model);

  @override
  _EditReviewDialogState createState() => _EditReviewDialogState();
}

class _EditReviewDialogState extends State<EditReviewDialog> {
  final _editReviewFormKey = GlobalKey<FormState>();

  TextEditingController? _title;
  TextEditingController? _review;

  bool _containsSpoilers = false;
  bool _showDelete = false;
  bool _ratingRefreshed = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.model.title);
    _review = TextEditingController(text: widget.model.content);
  }

  @override
  void dispose() {
    _title?.dispose();
    _review?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = widget.model.user;
    var movieId = widget.model.movieId;

    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: TitleText('Edit review'),
          contentPadding: EdgeInsets.only(left: 24, right: 24, bottom: 10),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20, width: 500),
              Form(
                key: _editReviewFormKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      maxLength: 50,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'You cannot have an empty title';
                        } else {
                          return '';
                        }
                      },
                      maxLines: null,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _title,
                      decoration: InputDecoration(
                        labelText: 'Edit review title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Your review cannot be empty.\nDid you mean to delete it?';
                        } else {
                          return '';
                        }
                      },
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _review,
                      decoration: InputDecoration(
                        labelText: 'Edit your review',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        SubtitleText('Contains spoilers:'),
                        Checkbox(
                          value: _containsSpoilers,
                          onChanged: (boo) => setState(() {
                            _containsSpoilers = !_containsSpoilers;
                          }),
                        ),
                      ],
                    ),
                    if (!_ratingRefreshed &&
                        widget.model.rating !=
                            currentUser.movieRatings['$movieId'])
                      TextButton.icon(
                        icon: Icon(Icons.refresh),
                        label: BodyText(
                          'Your rating doesn\'t match'
                          '\nTap to update',
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          widget.model.rating =
                              currentUser.movieRatings['$movieId'] ?? 0;
                          setState(() {
                            _ratingRefreshed = true;
                          });
                        },
                      ),
                    if (_ratingRefreshed)
                      BodyText(
                        'Rating refreshed, submit to make permanent',
                        overflow: TextOverflow.visible,
                      ),
                    if (_showDelete)
                      TextButton.icon(
                        icon: Icon(Icons.delete),
                        label: BodyText('Delete review!'),
                        onPressed: () {
                          widget.model.deleteReview(
                            reviewId: widget.model.reviewId,
                            authorId: widget.model.authorId,
                            movieId: widget.model.movieId,
                          );
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      )
                    else
                      TextButton(
                        child: BodyText('Tap to show \'delete review\' button',
                            color: Theme.of(context).errorColor),
                        onPressed: () => setState(() => _showDelete = true),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Wrap(
              children: <Widget>[
                TextButton.icon(
                  icon: Icon(Icons.cancel),
                  label: SubtitleText('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton.icon(
                  icon: Icon(Icons.check_circle),
                  label: SubtitleText('Submit'),
                  onPressed: () {
                    if (_editReviewFormKey.currentState!.validate()) {
                      widget.model.updateReview(
                        containsSpoilers: _containsSpoilers,
                        ncontent: _review!.text,
                        ntitle: _title!.text,
                        nrating: widget.model.rating,
                        reviewId: widget.model.reviewId,
                      );
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final UserModel model;

  EditUserDialog(this.model);

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _editUserFormKey = GlobalKey<FormState>();

  TextEditingController? _name;
  TextEditingController? _email;
  TextEditingController? _password;
  TextEditingController? _description;

  bool _emailNotValid = false;
  bool _showDelete = false;
  bool _validatingInput = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.model.user.name);
    _email = TextEditingController(text: widget.model.user.email);
    _password = TextEditingController(text: widget.model.user.password);
    _description = TextEditingController(text: widget.model.user.description);
  }

  @override
  void dispose() {
    _name?.dispose();
    _email?.dispose();
    _password?.dispose();
    _description?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.model.user;

    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: TitleText('Edit information'),
          contentPadding: EdgeInsets.only(left: 24, right: 24, bottom: 10),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20, width: 500),
              Form(
                key: _editUserFormKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      maxLength: 50,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'You cannot have an empty name';
                        } else {
                          return '';
                        }
                      },
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: 'Edit name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (val) {
                        if (val!.isEmpty ||
                            !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val)) {
                          return 'Enter a valid e-mail';
                        } else if (_emailNotValid) {
                          return 'E-mail already exists';
                        } else {
                          return '';
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: 'Edit your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Your password may not be empty';
                        } else {
                          return '';
                        }
                      },
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Edit your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      maxLines: null,
                      controller: _description,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Edit your description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_showDelete)
                      TextButton.icon(
                        icon: Icon(Icons.delete),
                        label: BodyText('Delete user!'),
                        onPressed: () {
                          widget.model.deleteUser(user.docId);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginModelProvider(),
                              ),
                              (route) => false);
                        },
                      )
                    else
                      TextButton(
                        child: BodyText(
                          'Tap to show \'delete user\' button',
                          color: Theme.of(context).errorColor,
                        ),
                        onPressed: () => setState(() => _showDelete = true),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            if (_validatingInput)
              CircularProgressIndicator()
            else
              Wrap(
                children: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.cancel),
                    label: SubtitleText('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.check_circle),
                    label: SubtitleText('Submit'),
                    onPressed: () async {
                      setState(() {
                        _validatingInput = true;
                      });

                      if (_email?.text != user.email)
                        await widget.model
                            .validateUserUpdate(_email!.text)
                            .then((boo) => _emailNotValid = boo);
                      else
                        _emailNotValid = false;

                      if (_editUserFormKey.currentState!.validate()) {
                        widget.model.updateUser(
                          email: _email!.text,
                          name: _name!.text,
                          password: _password!.text,
                          description: _description!.text,
                          userId: user.docId,
                        );
                        Navigator.pop(context, true);
                      } else {
                        setState(() {
                          _validatingInput = false;
                        });
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class CreateListDialog extends StatefulWidget {
  final UserModel model;

  CreateListDialog(this.model);

  @override
  _CreateListDialogState createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _createListFormKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();

  bool _validatingInput = false;
  bool _titleExists = false;
  bool _private = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: TitleText('Create new list'),
          contentPadding: EdgeInsets.symmetric(horizontal: 24),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20, width: 500),
              Form(
                key: _createListFormKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      maxLength: 50,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'You cannot have an empty title';
                        } else if (_titleExists) {
                          return 'Title already used';
                        } else {
                          return '';
                        }
                      },
                      textCapitalization: TextCapitalization.sentences,
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'List title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        SubtitleText('Private list:'),
                        Checkbox(
                          value: _private,
                          onChanged: (boo) => setState(() {
                            _private = !_private;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            if (_validatingInput)
              CircularProgressIndicator()
            else
              Wrap(
                children: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.cancel),
                    label: SubtitleText('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.check_circle),
                    label: SubtitleText('Create list'),
                    onPressed: () async {
                      setState(() {
                        _validatingInput = true;
                      });

                      await widget.model
                          .validateListTitle(_titleCtrl.text)
                          .then((boo) => _titleExists = boo);

                      if (_createListFormKey.currentState!.validate()) {
                        widget.model.createList(
                          title: _titleCtrl.text,
                          private: _private,
                        );

                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          _validatingInput = false;
                        });
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class EditListDialog extends StatefulWidget {
  final UserModel model;
  final String title;
  final bool private;
  final String listId;

  EditListDialog({
    required this.model,
    required this.title,
    required this.private,
    required this.listId,
  });

  @override
  _EditListDialogState createState() => _EditListDialogState();
}

class _EditListDialogState extends State<EditListDialog> {
  final _editListFormKey = GlobalKey<FormState>();

  TextEditingController? _titleCtrl;

  bool _validatingInput = false;
  bool _titleExists = false;
  bool _private = true;
  bool _showDelete = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.title);
    _private = widget.private;
  }

  @override
  void dispose() {
    _titleCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: TitleText('Edit list'),
          contentPadding: EdgeInsets.symmetric(horizontal: 24),
          content: Column(
            children: <Widget>[
              SizedBox(height: 20, width: 500),
              Form(
                key: _editListFormKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      maxLength: 50,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'You cannot have an empty title';
                        } else if (_titleExists) {
                          return 'Title already used';
                        } else {
                          return '';
                        }
                      },
                      textCapitalization: TextCapitalization.sentences,
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'List title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        SubtitleText('Private list:'),
                        Checkbox(
                          value: _private,
                          onChanged: (boo) => setState(() {
                            _private = !_private;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_showDelete)
                TextButton.icon(
                  icon: Icon(Icons.delete),
                  label: BodyText('Delete list!'),
                  onPressed: () {
                    widget.model.deleteList(
                      listId: widget.listId,
                      userId: widget.model.user.docId,
                    );
                    Navigator.pop(context, true);
                  },
                )
              else
                TextButton(
                  child: BodyText(
                    'Tap to show \'delete list\' button',
                    color: Theme.of(context).errorColor,
                  ),
                  onPressed: () => setState(() => _showDelete = true),
                ),
            ],
          ),
          actions: <Widget>[
            if (_validatingInput)
              CircularProgressIndicator()
            else
              Wrap(
                children: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.cancel),
                    label: SubtitleText('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.check_circle),
                    label: SubtitleText('Submit'),
                    onPressed: () async {
                      setState(() {
                        _validatingInput = true;
                      });

                      if (_titleCtrl?.text != widget.model.currentListTitle)
                        await widget.model
                            .validateListTitle(_titleCtrl!.text)
                            .then((boo) => _titleExists = boo);
                      else
                        _titleExists = false;

                      if (_editListFormKey.currentState!.validate()) {
                        widget.model.updateList(
                          title: _titleCtrl!.text,
                          private: _private,
                          listId: widget.listId,
                          userId: widget.model.user.docId,
                        );

                        widget.model.updateCurrentList(
                          currentListTitle: _titleCtrl!.text,
                          currentListPrivate: _private,
                          currentListId: widget.listId,
                        );

                        Navigator.pop(context, false);
                      } else {
                        setState(() {
                          _validatingInput = false;
                        });
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class SelectListDialog extends StatefulWidget {
  final MovieModel model;

  SelectListDialog(this.model);

  @override
  _SelectListDialogState createState() => _SelectListDialogState();
}

class _SelectListDialogState extends State<SelectListDialog> {
  Future<QuerySnapshot>? _future;

  @override
  void initState() {
    super.initState();
    /*_future = FirebaseFirestore.instance
        .collection('users/${widget.model.user.docId}/lists')
        .orderBy('date')
        .get();*/
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: TitleText('Select list'),
          contentPadding: EdgeInsets.symmetric(horizontal: 24),
          content: Container(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20, width: 500),
                FutureBuilder(
                  future: _future,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return CircularProgressIndicator();
                      default:
                        if (snapshot.hasError)
                          return SubtitleText('${snapshot.error}');
                        if (snapshot.data?.docs.length == 0)
                          return SubtitleText('No lists found');
                        return ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: <Widget>[
                            for (var doc in snapshot.data!.docs)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 15),
                                      child: Icon(
                                        Icons.lens,
                                      ),
                                    ),
                                    Expanded(
                                      child: Material(
                                        color: theme.backgroundColor,
                                        borderRadius: BorderRadius.circular(15),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 15,
                                            ),
                                            child: BodyText(
                                              doc['title'],
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          onTap: () {
                                            widget.model.insertMovieInList(
                                              movie: widget.model.movie,
                                              listId: doc.id,
                                              //userId: widget.model.user.docId,
                                            );
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.cancel),
              label: SubtitleText('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
