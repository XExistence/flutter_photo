part of '../photo_main_page.dart';

class _BottomWidget extends StatefulWidget {
  final ValueChanged<AssetPathEntity>? onGalleryChange;

  final Options? options;

  final I18nProvider? provider;

  final SelectedProvider? selectedProvider;

  final String galleryName;

  final GalleryListProvider? galleryListProvider;
  final VoidCallback? onTapPreview;

  const _BottomWidget({
    Key? key,
    this.onGalleryChange,
    this.options,
    this.provider,
    this.selectedProvider,
    this.galleryName = "",
    this.galleryListProvider,
    this.onTapPreview,
  }) : super(key: key);

  @override
  __BottomWidgetState createState() => __BottomWidgetState();
}

class __BottomWidgetState extends State<_BottomWidget> {
  Options? get options => widget.options;

  I18nProvider? get i18nProvider => widget.provider;

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(fontSize: 14.0);
    const textPadding = const EdgeInsets.symmetric(horizontal: 16.0);
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: options.dividerColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0.0,-4), //(x,y)
                blurRadius: 2.0,
              ),
            ],
          ),
          height: 52.0,
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10),
                width: 50,
                height: 50,
                child: RawMaterialButton(
                  onPressed: _showGallerySelectDialog,
                  elevation: 2.0,
                  child: SvgPicture.asset("assets/svg/folder.svg",
                      color: options.brightness == Brightness.dark ? options.textColor : Colors.black),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              ),
              Expanded(
                child: Container(),
              ),
//              FlatButton(
//                onPressed: widget.onTapPreview,
//                textColor: options.textColor,
//                splashColor: Colors.transparent,
//                disabledTextColor: options.disableColor,
//                child: Container(
//                  height: 44.0,
//                  alignment: Alignment.center,
//                  child: Text(
////                    i18nProvider.getPreviewText(
////                        options, widget.selectedProvider),
//                    "Preview",
//                    style: textStyle,
//                  ),
//                  padding: textPadding,
//                ),
//              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGallerySelectDialog() async {
    var result = await showModalBottomSheet(
      context: context,
      builder: (ctx) => ChangeGalleryDialog(
            galleryList: widget.galleryListProvider!.galleryPathList,
            i18n: i18nProvider,
            options: options,
          ),
    );

    if (result != null) widget.onGalleryChange?.call(result);
  }
}
