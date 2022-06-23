// Packages
import 'package:flutter/material.dart';

class RoundedImage extends StatelessWidget {
  final String path;
  final double height;
  final double? width;

  RoundedImage({
    required this.path,
    required this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/images/placeholder.png',
        image: '$path',
        fadeInDuration: Duration(milliseconds: 200),
        height: height,
        width: width,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}
