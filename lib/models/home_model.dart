// Packages
import 'package:flutter/material.dart';
import 'package:p4_cinebase/data/tmdb_data_parser.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
// Data
import '../data/repository.dart';
import '../data/firestore_data_parser.dart';

class HomeModel extends Model {
  final repository = Repository();

  User? _user;
  User? get user => _user;

  String _orderBy = '';
  String _category = '';
  int _voteCountMin = 0;
  String _releaseDateMin = '';
  String _releaseDateMax = '';
  String _genres = '';

  String get orderBy => _orderBy;
  String get category => _category;
  int get voteCountMin => _voteCountMin;
  String get releaseDateMin => _releaseDateMin;
  String get releaseDateMax => _releaseDateMax;
  String get genres => _genres;

  String _moviesShowing = '';
  IconData? _orderIcon;

  String get moviesShowing => _moviesShowing;
  IconData? get orderIcon => _orderIcon;

  bool _searching = false;
  bool get searching => _searching;

  late PagewiseLoadController<MovieElement>? _pageLoadController;
  get pagewiseController => _pageLoadController;

  HomeModel(this._user) {
    presets(id: 1);
    refreshPagewiseController();
  }

  void refreshPagewiseController() {
    _pageLoadController = PagewiseLoadController(
      pageSize: 20,
      pageFuture: (int? pageIndex) => repository.fetchMovies(
        page: pageIndex ?? 0,
        orderBy: _orderBy,
        category: _category,
        voteCountMin: _voteCountMin,
        releaseDateMin: _releaseDateMin,
        releaseDateMax: _releaseDateMax,
        genres: _genres,
      ),
    );
    notifyListeners();
  }

  void updateHomePageTitle({String? title, bool? icon}) {
    if (title != null) {
      _moviesShowing = title;
    } else if (_category == 'popularity') {
      _moviesShowing = 'Popularity';
    } else if (_category == 'primary_release_date') {
      _moviesShowing = 'Release date';
    } else if (_category == 'vote_average') {
      _moviesShowing = 'Rating';
    }

    if (_orderBy == 'desc') {
      _orderIcon = Icons.arrow_downward;
    } else if (_orderBy == 'asc') {
      _orderIcon = Icons.arrow_upward;
    }
  }

  void updateFilters({
    String? orderBy,
    String? category,
    int? voteCountMin,
    String? releaseDateMin,
    String? releaseDateMax,
    String? genres,
    String? title,
  }) {
    _orderBy = orderBy ?? _orderBy;
    _category = category ?? _category;
    _voteCountMin = voteCountMin ?? _voteCountMin;
    _releaseDateMin = releaseDateMin ?? _releaseDateMin;
    _releaseDateMax = releaseDateMax ?? _releaseDateMax;
    _genres = genres ?? _genres;

    notifyListeners();
  }

  void addGenre(String genre) {
    _genres = _genres + genre;
    notifyListeners();
  }

  void removeGenre(String genre) {
    _genres = _genres.replaceAll('$genre', '');
    notifyListeners();
  }

  void presets({required int id}) {
    if (id == 1) {
      updateFilters(
        orderBy: 'desc',
        category: 'popularity',
        voteCountMin: 100,
        releaseDateMin: '',
        releaseDateMax: '',
        genres: '',
      );
      updateHomePageTitle(title: 'Popular now', icon: false);
    } else if (id == 2) {
      updateFilters(
        orderBy: 'desc',
        category: 'vote_average',
        voteCountMin: 1000,
        releaseDateMin: '',
        releaseDateMax: '',
        genres: '',
      );
      updateHomePageTitle(title: 'Top rated', icon: false);
    } else if (id == 3) {
      updateFilters(
        orderBy: 'desc',
        category: 'popularity',
        voteCountMin: 0,
        releaseDateMin: '${DateTime.now()}'.substring(0, 10),
        releaseDateMax:
            '${DateTime.now().add(Duration(days: 31))}'.substring(0, 10),
        genres: '',
      );
      updateHomePageTitle(title: 'Upcoming', icon: false);
    }

    refreshPagewiseController();
  }

  List<dynamic> backupFilters() {
    String orderByBak = _orderBy;
    String categoryBak = _category;
    int voteCountBak = _voteCountMin;
    String releaseDateMinBak = _releaseDateMin;
    String releaseDateMaxBak = _releaseDateMax;
    String genresBak = _genres;

    return [
      orderByBak,
      categoryBak,
      voteCountBak,
      releaseDateMinBak,
      releaseDateMaxBak,
      genresBak,
    ];
  }

  void setSearching(bool boo) {
    _searching = boo;
    notifyListeners();
  }

  void search(String str) {
    _pageLoadController = PagewiseLoadController(
      pageSize: 20,
      pageFuture: (int? pageIndex) => repository.fetchMovies(
        page: pageIndex ?? 0,
        query: str,
      ),
    );
    _searching = false;
    _moviesShowing = 'Results: $str';
    notifyListeners();
  }

  bool backIfSearching() {
    presets(id: 1);
    refreshPagewiseController();
    setSearching(false);
    return false;
  }
}
