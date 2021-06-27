import 'package:flutter/material.dart';
import 'package:photo/src/ui/widget/single_loading_indicator.dart';
import 'package:photo/src/ui/widget/single_loading_indicator.dart';
import 'package:photo_manager/photo_manager.dart';

abstract class LoadingDelegate {
  Widget buildBigImageLoading(
      BuildContext context, AssetEntity entity, Color? themeColor);

  Widget buildPreviewLoading(
      BuildContext context, AssetEntity? entity, Color? themeColor);
}

class DefaultLoadingDelegate extends LoadingDelegate {
  @override
  Widget buildBigImageLoading(
      BuildContext context, AssetEntity entity, Color? themeColor) {
    return Center(
      child: Container(
        width: 30.0,
        height: 30.0,
        child: SingleLoadingIndicator(
          padding: EdgeInsets.all(10),
        ),
      ),
    );
  }

  @override
  Widget buildPreviewLoading(
      BuildContext context, AssetEntity? entity, Color? themeColor) {
    return Center(
      child: Container(
        width: 30.0,
        height: 30.0,
        child: SingleLoadingIndicator(
          padding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
