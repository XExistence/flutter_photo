import 'package:flutter/material.dart';
import 'package:photo/src/delegate/badge_delegate.dart';
import 'package:photo/src/delegate/checkbox_builder_delegate.dart';
import 'package:photo/src/delegate/loading_delegate.dart';
import 'package:photo/src/delegate/sort_delegate.dart';

class Options {
  final int? rowCount;

  final int? maxSelected;

  final double? padding;

  final double? itemRadio;

  final Color? backgroundColor;

  final Color? color;

  final Color dividerColor;

  final Color? textColor;

  final Color? disableColor;

  final int? thumbSize;

  final SortDelegate? sortDelegate;

  final CheckBoxBuilderDelegate? checkBoxBuilderDelegate;

  final LoadingDelegate? loadingDelegate;

  final BadgeDelegate? badgeDelegate;

  final PickType? pickType;

  final Brightness brightness;

  final Widget logo;

  const Options(
      {this.rowCount,
      this.maxSelected,
      this.padding,
      this.itemRadio,
      required this.backgroundColor,
      required this.color,
      required this.dividerColor,
      required this.logo,
      this.textColor,
      this.disableColor,
      this.thumbSize,
      this.sortDelegate,
      this.checkBoxBuilderDelegate,
      this.loadingDelegate,
      this.badgeDelegate,
      this.pickType,
      required this.brightness});
}

enum PickType {
  all,
  onlyImage,
  onlyVideo,
}
