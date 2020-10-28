import 'package:Social/groups/CreatePost.dart';
import 'package:Social/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageGallery extends StatefulWidget {
  final dynamic groupID;
  ImageGallery(this.groupID);
  @override
  _ImageGalleryState createState() => _ImageGalleryState(this.groupID);
}

class _ImageGalleryState extends State<ImageGallery> {
  List<AssetEntity> _mediaList = [];
  var _selectedImage;
  int currentPage = 0;
  int lastPage;
  dynamic groupID;

  _ImageGalleryState(this.groupID);

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  Future<dynamic> _firstMediaThumb() async {
    return await _mediaList[0].thumbData;
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
//load the album list
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(hasAll: true);
      List<AssetEntity> media =
          await albums[0].assetList;
      print(albums[0]);
      setState(() {
        _mediaList.addAll(media);
        currentPage++;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: background,
        body: FutureBuilder(
            future: _firstMediaThumb(),
            builder: (context, firstImage) {
              if (firstImage.hasError) {
                return Text('Something went wrong');
              }

              if (firstImage.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return CustomScrollView(slivers: [
                SliverAppBar(
                  actions: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreatePost(
                                      groupID,
                                      _selectedImage == null
                                          ? firstImage.data
                                          : _selectedImage,
                                    )));
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                              alignment: Alignment.center,
                              child: Text('Next',
                                  style: TextStyle(
                                      color: forground,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)))),
                    )
                  ],
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.cancel,
                      size: 23,
                    ),
                  ),
                  backgroundColor: background,
                  expandedHeight: 350,
                  elevation: 0,
                  iconTheme: IconThemeData(color: forground, size: 30.0),
                  flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.memory(
                            _selectedImage == null
                                ? firstImage.data
                                : _selectedImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (_mediaList[0].type == AssetType.video)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 5, bottom: 5),
                              child: Icon(
                                Icons.videocam,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
                  floating: true,
                  pinned: true,
                  title: Text(
                    'Gallery',
                    style: TextStyle(color: forground),
                  ),
                ),
                SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return FutureBuilder(
                          future: _mediaList[index].thumbData,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done)
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = snapshot.data;
                                  });
                                },
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.transparent, width: 1)),
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned.fill(
                                        child: Image.memory(
                                          snapshot.data,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (_mediaList[index].type ==
                                          AssetType.video)
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 5, bottom: 5),
                                            child: Icon(
                                              Icons.videocam,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            return Container();
                          },
                        );
                      },
                      childCount: _mediaList.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3))
              ]);
            }));
  }
}
