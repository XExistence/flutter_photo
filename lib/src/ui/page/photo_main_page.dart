import 'dart:async';
import 'dart:typed_data';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo/src/delegate/badge_delegate.dart';
import 'package:photo/src/delegate/loading_delegate.dart';
import 'package:photo/src/engine/lru_cache.dart';
import 'package:photo/src/engine/throttle.dart';
import 'package:photo/src/entity/options.dart';
import 'package:photo/src/provider/asset_provider.dart';
import 'package:photo/src/provider/config_provider.dart';
import 'package:photo/src/provider/gallery_list_provider.dart';
import 'package:photo/src/provider/i18n_provider.dart';
import 'package:photo/src/provider/selected_provider.dart';
import 'package:photo/src/ui/dialog/change_gallery_dialog.dart';
import 'package:photo/src/ui/page/photo_preview_page.dart';
import 'package:photo/src/ui/widget/single_loading_indicator.dart';
import 'package:photo_manager/photo_manager.dart';

part './main/bottom_widget.dart';
part './main/image_item.dart';

class PhotoMainPage extends StatefulWidget {
  final ValueChanged<List<AssetEntity>>? onClose;
  final Options options;
  final List<AssetPathEntity>? photoList;

  const PhotoMainPage({
    Key? key,
    this.onClose,
    required this.options,
    this.photoList,
  }) : super(key: key);

  @override
  _PhotoMainPageState createState() => _PhotoMainPageState();
}

class _PhotoMainPageState extends State<PhotoMainPage>
    with SelectedProvider, GalleryListProvider {
  Options get options => widget.options;

  I18nProvider? get i18nProvider => PhotoPickerProvider.of(context)!.provider;
  AssetProvider get assetProvider =>
      PhotoPickerProvider.of(context)!.assetProvider;

  List<AssetEntity> get list => assetProvider.data;

  Color? get themeColor => options.themeColor;

  AssetPathEntity? currentPath;

  bool _isInit = false;

  String get currentGalleryName {
    if (currentPath?.isAll == true) {
      return i18nProvider!.getAllGalleryText(options);
    } else if (currentPath == null) {
      return i18nProvider!.getNoSelectedText(options);
    }
    return currentPath?.name ?? "Select Folder";
  }

  GlobalKey? scaffoldKey;
  ScrollController? scrollController;

  bool isPushed = false;

  bool get useAlbum => widget.photoList == null || widget.photoList!.isEmpty;

  late Throttle _changeThrottle;

  @override
  void initState() {
    super.initState();
    scaffoldKey = GlobalKey();
    scrollController = ScrollController();
    _changeThrottle = Throttle(onCall: _onAssetChange);
    PhotoManager.addChangeCallback(_changeThrottle.call);
    PhotoManager.startChangeNotify();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final pickedList = PhotoPickerProvider.of(context)!.pickedAssetList ?? [];
      addPickedAsset(pickedList.toList());
      _refreshList();
    }
  }

  @override
  void dispose() {
    PhotoManager.removeChangeCallback(_changeThrottle.call);
    PhotoManager.stopChangeNotify();
    _changeThrottle.dispose();
    scaffoldKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: options.textColor,
      fontSize: 14.0,
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        brightness: options.brightness,
        backgroundColor: widget.options.dividerColor,
        leading: IconButton(
          icon: Icon(
            EvaIcons.close,
            size: 29,
            color: options.brightness == Brightness.dark
                ? options.textColor
                : Colors.black,
          ),
          onPressed: _cancel,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: options.logo,
            )
          ],
        ),
        actions: <Widget>[
          Container(
            width: 50,
            height: 50,
            child: RawMaterialButton(
              onPressed: selectedCount == 0 ? null : sure,
              elevation: 2.0,
              child: Icon(
                EvaIcons.checkmarkCircle2Outline,
                size: 25,
                color: options.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            ),
          )
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _BottomWidget(
        key: scaffoldKey,
        provider: i18nProvider,
        options: options,
        galleryName: currentGalleryName,
        onGalleryChange: _onGalleryChange,
        onTapPreview: selectedList.isEmpty ? null : _onTapPreview,
        selectedProvider: this,
        galleryListProvider: this,
      ),
    );
  }

  void _cancel() {
    selectedList.clear();
    widget.onClose!(selectedList);
  }

  @override
  bool isUpperLimit() {
    var result = selectedCount == options.maxSelected;
    if (result) _showTip(i18nProvider!.getMaxTipText(options));
    return result;
  }

  void sure() {
    widget.onClose?.call(selectedList);
  }

  void _showTip(String msg) {
    if (isPushed) {
      return;
    }
    Scaffold.of(scaffoldKey!.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            color: options.textColor,
            fontSize: 14.0,
          ),
        ),
        duration: Duration(milliseconds: 1500),
        backgroundColor: themeColor!.withOpacity(0.7),
      ),
    );
  }

  void _refreshList() async {
    await Future.delayed(Duration.zero);
    if (!useAlbum) {
      _refreshListFromWidget();
      return;
    }

    _refreshListFromGallery();
  }

  Future<void> _refreshListFromWidget() async {
    _onRefreshAssetPathList(widget.photoList);
  }

  Future<void> _refreshListFromGallery() async {
    List<AssetPathEntity> pathList;
    switch (options.pickType) {
      case PickType.onlyImage:
        pathList = await PhotoManager.getAssetPathList(type: RequestType.image);
        break;
      case PickType.onlyVideo:
        pathList = await PhotoManager.getAssetPathList(type: RequestType.video);
        break;
      default:
        pathList = await PhotoManager.getAssetPathList(
            type: RequestType.image | RequestType.video);
    }

    _onRefreshAssetPathList(pathList);
  }

  Future<void> _onRefreshAssetPathList(List<AssetPathEntity>? pathList) async {
    if (pathList == null) {
      return;
    }

    options.sortDelegate!.sort(pathList);

    galleryPathList.clear();
    galleryPathList.addAll(pathList);

    if (pathList.isNotEmpty) {
      assetProvider.current = pathList[0];
      await assetProvider.loadMore();
    }

    // for (var path in pathList) {
    //   if (path.isAll) {
    //     path.name = i18nProvider!.getAllGalleryText(options);
    //   }
    // }

    setState(() {
      _isInit = true;
    });
  }

  Widget _buildBody() {
    if (!_isInit) {
      return _buildLoading();
    }

    final noMore = assetProvider.noMore;

    final count = assetProvider.count + (noMore ? 0 : 1);

    return Container(
      color: options.dividerColor,
      child: GridView.builder(
        controller: scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: options.rowCount!,
          childAspectRatio: options.itemRadio!,
          crossAxisSpacing: options.padding!,
          mainAxisSpacing: options.padding!,
        ),
        itemBuilder: _buildItem,
        itemCount: count,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final noMore = assetProvider.noMore;
    if (!noMore && index == assetProvider.count) {
      _loadMore();
      return _buildLoading();
    }

    var data = list[index];
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _onItemClick(data, index),
        child: Stack(
          children: <Widget>[
            ImageItem(
              entity: data,
              themeColor: themeColor,
              size: options.thumbSize,
              loadingDelegate: options.loadingDelegate,
              badgeDelegate: options.badgeDelegate,
            ),
            _buildMask(containsEntity(data)),
            _buildSelected(data),
          ],
        ),
      ),
    );
  }

  _loadMore() async {
    await assetProvider.loadMore();
    setState(() {});
  }

  _buildMask(bool showMask) {
    return IgnorePointer(
      child: AnimatedContainer(
        color: showMask ? Colors.black.withOpacity(0.5) : Colors.transparent,
        duration: Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildSelected(AssetEntity entity) {
    var currentSelected = containsEntity(entity);
    return Container(
      child: GestureDetector(
        onTap: () {
          changeCheck(!currentSelected, entity);
        },
        behavior: HitTestBehavior.translucent,
        child: _buildText(entity),
      ),
    );
  }

  Widget _buildText(AssetEntity entity) {
    var isSelected = containsEntity(entity);
    Widget? child;
    BoxDecoration decoration;
    if (isSelected) {
      child = Text(
        (indexOfSelected(entity) + 1).toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.0,
          color: options.textColor,
        ),
      );
      decoration = BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: themeColor);
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(1.0),
        border: Border.all(
          color: Colors.transparent,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(),
          Center(
            child: AnimatedContainer(
              width: 30,
              height: 30,
              duration: Duration(milliseconds: 200),
              decoration: decoration,
              alignment: Alignment.center,
              child: child,
            ),
          )
        ],
      ),
    );
  }

  void changeCheck(bool value, AssetEntity entity) {
    if (value) {
      addSelectEntity(entity);
    } else {
      removeSelectEntity(entity);
    }
    setState(() {});
  }

  void _onGalleryChange(AssetPathEntity? assetPathEntity) async {
    // _currentPath = assetPathEntity;

    // _currentPath.assetList.then((v) async {
    //   _sortAssetList(v);
    //   list.clear();
    //   list.addAll(v);
    //   scrollController.jumpTo(0.0);
    //   await checkPickImageEntity();
    //   setState(() {});
    // });
    if (assetPathEntity != assetProvider.current) {
      assetProvider.current = assetPathEntity!;
      await assetProvider.loadMore();
      setState(() {});
    }
  }

  void _onItemClick(AssetEntity data, int index) {
    var result = PhotoPreviewResult();
    isPushed = true;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return PhotoPickerProvider(
            provider: PhotoPickerProvider.of(context)!.provider,
            options: options,
            child: PhotoPreviewPage(
              selectedProvider: this,
              list: List.of(list),
              initIndex: index,
              changeProviderOnCheckChange: true,
              result: result,
              isPreview: false,
              assetProvider: assetProvider,
            ),
          );
        },
      ),
    ).then((v) {
      if (handlePreviewResult(v)) {
        Navigator.pop(context, v);
        return;
      }
      isPushed = false;
      setState(() {});
    });
  }

  void _onTapPreview() async {
    var result = PhotoPreviewResult();
    isPushed = true;
    var v = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PhotoPickerProvider(
          provider: PhotoPickerProvider.of(context)!.provider,
          options: options,
          child: PhotoPreviewPage(
            selectedProvider: this,
            list: List.of(selectedList),
            changeProviderOnCheckChange: false,
            result: result,
            isPreview: true,
            assetProvider: assetProvider,
          ),
        ),
      ),
    );
    if (handlePreviewResult(v)) {
      // print(v);
      Navigator.pop(context, v);
      return;
    }
    isPushed = false;
    compareAndRemoveEntities(result.previewSelectedList);
  }

  bool handlePreviewResult(List<AssetEntity>? v) {
    if (v == null) {
      return false;
    }
    if (v is List<AssetEntity>) {
      return true;
    }
    return false;
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            width: 40.0,
            height: 40.0,
            padding: const EdgeInsets.all(5.0),
            child: SingleLoadingIndicator(
              padding: EdgeInsets.all(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              i18nProvider!.loadingText(),
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void _onAssetChange() {
    if (useAlbum) {
      _onPhotoRefresh();
    }
  }

  void _onPhotoRefresh() async {
    List<AssetPathEntity> pathList;
    switch (options.pickType) {
      case PickType.onlyImage:
        pathList = await PhotoManager.getAssetPathList(type: RequestType.image);
        break;
      case PickType.onlyVideo:
        pathList = await PhotoManager.getAssetPathList(type: RequestType.image);
        break;
      default:
        pathList = await PhotoManager.getAssetPathList();
    }

    if (pathList == null) {
      return;
    }

    this.galleryPathList.clear();
    this.galleryPathList.addAll(pathList);

    if (!this.galleryPathList.contains(this.currentPath)) {
      // current path is deleted , 当前的相册被删除, 应该提示刷新
      if (this.galleryPathList.length > 0) {
        _onGalleryChange(this.galleryPathList[0]);
      }
      return;
    }
    // Not deleted
    _onGalleryChange(this.currentPath);
  }
}
