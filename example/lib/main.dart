import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';

import './preview.dart';
import 'icon_text_button.dart';
import 'picked_example.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'Pick Image Demo',
        theme: ThemeData(
          primarySwatch: Colors.lime,
        ),
        home: MyHomePage(title: 'Pick Image Demo'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with  LoadingDelegate {
  String currentSelected = "";

  @override
  Widget buildBigImageLoading(
      BuildContext context, AssetEntity entity, Color themeColor) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        child: CupertinoActivityIndicator(
          radius: 25.0,
        ),
      ),
    );
  }

  @override
  Widget buildPreviewLoading(
      BuildContext context, AssetEntity entity, Color themeColor) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        child: CupertinoActivityIndicator(
          radius: 25.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          ElevatedButton(
            child: Icon(Icons.image),
            onPressed: _testPhotoListParams,
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              IconTextButton(
                icon: Icons.photo,
                text: "photo",
                onTap: () => _pickAsset(PickType.onlyImage),
              ),
              IconTextButton(
                icon: Icons.videocam,
                text: "video",
                onTap: () => _pickAsset(PickType.onlyVideo),
              ),
              IconTextButton(
                icon: Icons.album,
                text: "all",
                onTap: () => _pickAsset(PickType.all),
              ),
              IconTextButton(
                icon: CupertinoIcons.reply_all,
                text: "Picked asset example.",
                onTap: () => routePage(PickedExample()),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAsset(PickType.all),
        tooltip: 'pickImage',
        child: Icon(Icons.add),
      ),
    );
  }

  void _testPhotoListParams() async {
    var assetPathList =
        await PhotoManager.getAssetPathList(type: RequestType.image);
    _pickAsset(PickType.all, pathList: assetPathList);
  }

  Map<int, Color> colorCodes = {
    50: Color.fromRGBO(22, 22, 22, .1),
    100: Color.fromRGBO(22, 22, 22, .2),
    200: Color.fromRGBO(22, 22, 22, .3),
    300: Color.fromRGBO(22, 22, 22, .4),
    400: Color.fromRGBO(22, 22, 22, .5),
    500: Color.fromRGBO(22, 22, 22, .6),
    600: Color.fromRGBO(22, 22, 22, .7),
    700: Color.fromRGBO(22, 22, 22, .8),
    800: Color.fromRGBO(22, 22, 22, .9),
    900: Color.fromRGBO(22, 22, 22, 1),
  };

  void _pickAsset(PickType type, {List<AssetPathEntity> pathList}) async {
    /// context is required, other params is optional.
    /// context is required, other params is optional.
    /// context is required, other params is optional.

    PhotoPicker.clearThumbMemoryCache();

    List<AssetEntity> imgList = await PhotoPicker.pickAsset(
      context: context,
      color: Colors.red,
      backgroundColor:
          MaterialColor(Color.fromARGB(255, 21, 21, 21).value, colorCodes),
      logo: Container(
        width: 30,
        height: 30,
        color: Colors.red,
      ),
      brightness: Brightness.dark,
      textColor: Colors.white,
      padding: 1.0,
      dividerColor:
          MaterialColor(Color.fromARGB(255, 45, 45, 45).value, colorCodes),
      disableColor: Colors.grey.shade300,
      itemRadio: 0.88,
      maxSelected: 8,
      provider: I18nProvider.english,
      rowCount: 3,
      thumbSize: 150,
      sortDelegate: SortDelegate.common,
      checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
        activeColor: Colors.white,
        unselectedColor: Colors.white,
        checkColor: Colors.green,
      ),
      loadingDelegate: this,
      badgeDelegate: const DurationBadgeDelegate(),
      pickType: type,
      photoPathList: pathList,
    );

    if (imgList == null || imgList.isEmpty) {
      showToast("No pick item.");
      return;
    } else {
      List<String> r = [];
      for (var e in imgList) {
        var file = await e.file;
        r.add(file.absolute.path);
      }
      currentSelected = r.join("\n\n");

      List<AssetEntity> preview = [];
      preview.addAll(imgList);
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => PreviewPage(list: preview)));
    }
    setState(() {});
  }

  void routePage(Widget widget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      ),
    );
  }
}
