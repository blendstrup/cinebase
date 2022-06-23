// Packages
import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final Color? color;
  final String data;
  final EdgeInsets? padding;
  final TextAlign textAlign;
  final double? fontSize;

  TitleText(
    this.data, {
    this.color,
    this.padding,
    this.textAlign: TextAlign.start,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0.0),
      child: Text(
        '$data',
        textAlign: textAlign,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.headline1?.copyWith(
              color: color ?? Theme.of(context).textTheme.headline1?.color,
              fontSize: fontSize,
            ),
      ),
    );
  }
}

class SubtitleText extends StatelessWidget {
  final Color? color;
  final String data;
  final EdgeInsets? padding;
  final TextAlign textAlign;

  SubtitleText(
    this.data, {
    this.color,
    this.padding,
    this.textAlign: TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0.0),
      child: Text(
        '$data',
        textAlign: textAlign,
        style: Theme.of(context).textTheme.subtitle1?.copyWith(
            color: color ?? Theme.of(context).textTheme.subtitle1?.color),
      ),
    );
  }
}

class CaptionText extends StatelessWidget {
  final Color? color;
  final String data;
  final int? maxLines;
  final TextOverflow overflow;
  final EdgeInsets? padding;
  final TextAlign textAlign;

  CaptionText(
    this.data, {
    this.color,
    this.maxLines,
    this.overflow: TextOverflow.ellipsis,
    this.padding,
    this.textAlign: TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0.0),
      child: Text(
        '$data',
        style: Theme.of(context).textTheme.caption?.copyWith(
            color: color ?? Theme.of(context).textTheme.caption?.color),
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
      ),
    );
  }
}

class BodyText extends StatelessWidget {
  final Color? color;
  final String data;
  final int? maxLines;
  final TextOverflow overflow;
  final EdgeInsets? padding;
  final TextAlign textAlign;
  final FontWeight? fontWeight;

  BodyText(
    this.data, {
    this.color,
    this.maxLines,
    this.overflow: TextOverflow.ellipsis,
    this.padding,
    this.textAlign: TextAlign.start,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0.0),
      child: Text(
        '$data',
        style: Theme.of(context).textTheme.bodyText1?.copyWith(
              color: color ?? Theme.of(context).textTheme.bodyText1?.color,
              fontWeight: fontWeight,
            ),
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
      ),
    );
  }
}
