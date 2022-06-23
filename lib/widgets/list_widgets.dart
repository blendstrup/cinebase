// Packages
import 'package:flutter/material.dart';
// Widgets
import 'text_widgets.dart';

class BlankListItem extends StatelessWidget {
  final String title;
  final String listId;
  final void Function() onTap;

  BlankListItem({
    required this.title,
    required this.listId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/images/placeholder.png',
                    color: Theme.of(context).cardColor,
                    colorBlendMode: BlendMode.src,
                    height: 200,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.sentiment_dissatisfied,
                        color: Theme.of(context).disabledColor,
                        size: 40,
                      ),
                      BodyText(
                        'Empty...',
                        color: Theme.of(context).disabledColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BodyText(
            title,
            maxLines: 2,
            fontWeight: FontWeight.bold,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SingleListItem extends StatelessWidget {
  final String path;
  final String title;
  final String listId;
  final void Function() onTap;

  SingleListItem({
    required this.path,
    required this.title,
    required this.listId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Container(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/placeholder.png',
                    image: '$path',
                    fadeInDuration: Duration(milliseconds: 200),
                    height: 200,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ],
            ),
          ),
          BodyText(
            title,
            maxLines: 2,
            fontWeight: FontWeight.bold,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DoubleListItem extends StatelessWidget {
  final String path1;
  final String path2;
  final String title;
  final String listId;
  final void Function() onTap;

  DoubleListItem({
    required this.path1,
    required this.path2,
    required this.title,
    required this.listId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Container(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/placeholder.png',
                    image: '$path2',
                    fadeInDuration: Duration(milliseconds: 200),
                    height: 200,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                ClipPath(
                  clipper: SplitClipperHalfway(),
                  child: Container(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/placeholder.png',
                      image: '$path1',
                      fadeInDuration: Duration(milliseconds: 200),
                      height: 200,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          BodyText(
            title,
            maxLines: 2,
            fontWeight: FontWeight.bold,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TripleListItem extends StatelessWidget {
  final String path1;
  final String path2;
  final String path3;
  final String title;
  final String listId;
  final void Function() onTap;

  TripleListItem({
    required this.path1,
    required this.path2,
    required this.path3,
    required this.title,
    required this.listId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Container(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/placeholder.png',
                    image: '$path3',
                    fadeInDuration: Duration(milliseconds: 200),
                    height: 200,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                ClipPath(
                  clipper: SplitClipperLastThird(),
                  child: Container(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/placeholder.png',
                      image: '$path2',
                      fadeInDuration: Duration(milliseconds: 200),
                      height: 200,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                ClipPath(
                  clipper: SplitClipperFirstThird(),
                  child: Container(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/placeholder.png',
                      image: '$path1',
                      fadeInDuration: Duration(milliseconds: 200),
                      height: 200,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          BodyText(
            title,
            maxLines: 2,
            fontWeight: FontWeight.bold,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SplitClipperHalfway extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SplitClipperHalfway oldClipper) => false;
}

class SplitClipperFirstThird extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * 0.50, 0.0);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SplitClipperFirstThird oldClipper) => false;
}

class SplitClipperLastThird extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height * 0.0);
    path.lineTo(size.width * 0.50, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SplitClipperLastThird oldClipper) => false;
}
