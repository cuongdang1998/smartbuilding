import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(Size(1000, 600));
    setWindowMaxSize(Size.infinite);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart building',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;
  Size imagesize;
  double maxWidth;
  double maxHeight;
  GlobalKey imagekey = GlobalKey();
  GlobalKey deskkey = GlobalKey();
  StreamController streamController = StreamController<File>.broadcast();
  List<Offset> rateOffsets = [
    // Offset(1 / 5, 2 / 3),
    // Offset(1 / 3, 2 / 9),
    // Offset(1 / 10, 1 / 2),
    // Offset(1 / 5, 11 / 20),
    // Offset(2 / 3, 5 / 6),
    // Offset(5 / 9, 3 / 10),
    // Offset(2 / 9, 13 / 21),
    // Offset(13 / 29, 13 / 20),
    // Offset(1, 1),
  ];
  List<Offset> realOffsets = [];
  Future _getImageFromTablet() async {
    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image != null) {
      _image = File(image?.path);
    }
    return _image;
  }

  Future _getImageFromDesktop() async {
    try {
      FilePickerCross file =
          await FilePickerCross.importFromStorage(type: FileTypeCross.image);
      if (file != null) {
        _image = File(file.path);
      }
      return _image;
    } catch (ex) {
      print(ex.toString());
    }
  }

  getImageSize() {
    RenderBox render = imagekey.currentContext.findRenderObject();
    imagesize = render.size;
    maxWidth = imagesize.width - 50;
    maxHeight = imagesize.height - 50;
    setState(() {
      convertOffet();
    });
  }

  convertOffet() {
    realOffsets = rateOffsets
        .map((e) => Offset(e.dx * (maxWidth), e.dy * (maxHeight)))
        .toList();
  }

  Offset getOffset({double dx, double dy, double maxWidth, double maxHeight}) {
    var offset;
    if (dx < 0 && dy < 0) {
      offset = Offset(0, 0);
      print("1 offset: ${offset}");
    } else if (dx < 0 && (dy >= 0 && dy <= maxHeight)) {
      offset = Offset(0, dy);
      print("2 offset: ${offset}");
    } else if (dx > maxWidth && (dy >= 0 && dy <= maxHeight)) {
      offset = Offset(maxWidth, dy);
      print("3 offset: ${offset}");
    } else if (dx > maxWidth && dy < 0) {
      offset = Offset(maxWidth, 0);
      print("4 offset: ${offset}");
    } else if (dx >= 0 && dx <= maxWidth && dy < 0) {
      offset = Offset(dx, 0);
      print("5 offset: ${offset}");
    } else if ((dx >= 0 && dx <= maxWidth) && dy > maxHeight) {
      offset = Offset(dx, maxHeight);
      print("6 offset: ${offset}");
    } else if (dx >= 0 && dx <= maxWidth && dy >= 0 && dy <= maxHeight) {
      offset = Offset(dx, dy);
      print("7 offset: ${offset}");
    } else if (dx > maxWidth && dy > maxHeight) {
      offset = Offset(maxWidth, maxHeight);
      print("8 offset: ${offset}");
    } else if (dx < 0 && dy > maxHeight) {
      offset = Offset(0, maxHeight);
      print("9 offset: ${offset}");
    }
    return offset;
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowMinSize(Size(1000, 600));
      setWindowMaxSize(Size.infinite);
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getImageSize());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((_) => getImageSize());
    return Scaffold(
      body: StreamBuilder<File>(
          stream: streamController.stream,
          builder: (context, snapshot) {
            return Container(
              padding: EdgeInsets.all(50),
              child: Column(
                children: [
                  Expanded(
                    key: imagekey,
                    child: snapshot.hasData
                        ? Container(
                            child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: double.infinity,
                                width: size.width,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.red, width: 1)),
                                child: Image.file(
                                  snapshot.data,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Stack(clipBehavior: Clip.none, children: [
                                ...realOffsets.asMap().entries.map((o) {
                                  return DeskWidget(
                                    offset: o.value,
                                    onPanUpdate: (detail) {
                                      var dx = realOffsets[o.key].dx +
                                          detail.delta.dx;
                                      var dy = realOffsets[o.key].dy +
                                          detail.delta.dy;
                                      print(
                                          "onmove : dx: ${dx} - dy: ${dy} - maxWidth: ${maxWidth} maxHeight: ${maxHeight}");
                                      setState(() {
                                        var offset = getOffset(
                                            dx: dx,
                                            dy: dy,
                                            maxHeight: maxHeight,
                                            maxWidth: maxWidth);
                                        realOffsets[o.key] = offset;
                                        rateOffsets[o.key] = Offset(
                                            offset.dx / maxWidth,
                                            offset.dy / maxHeight);
                                      });
                                    },
                                    ontap: () {
                                      print(
                                          "okey: ${o.key} offset: ${realOffsets[o.key].dx} - ${realOffsets[o.key].dy}");
                                      buildShowDialog(context, o);
                                    },
                                    onLongPress: () {
                                      realOffsets.removeAt(o.key);
                                      rateOffsets.removeAt(o.key);
                                      setState(() {});
                                    },
                                  );
                                }).toList(),
                              ]),
                            ],
                          ))
                        : Container(
                            width: size.width,
                            child: GestureDetector(
                              onTap: () async {},
                              child: Container(
                                child: Icon(
                                  Icons.image,
                                  size: 300,
                                ),
                              ),
                            ),
                          ),
                  ),
                  Container(
                    height: size.height * .2,
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        /// Use draggable
                        Draggable(
                          childWhenDragging: buildDeskItem(),
                          child: buildDeskItem(),
                          feedback: buildDeskItem(),
                          onDragEnd: (DraggableDetails details) {
                            developer.log('build details ${details.offset}',
                                name: 'Main');
                            setState(() {
                              if (snapshot.hasData) {
                                if (details.offset >= Offset(50, 50) &&
                                    details.offset <=
                                        Offset(imagesize.width,
                                            imagesize.height)) {
                                  // Add offset to real offset list
                                  //Must delete Offset(50,50) because padding(50)
                                  realOffsets
                                      .add(details.offset - Offset(50, 50));
                                  print("realOffsets: ${realOffsets}");
                                  // Add offset to rate offset list
                                  // Minus 50 because the width of desk is 50
                                  //And must convert to rate offset.
                                  rateOffsets.add(Offset(
                                      (details.offset.dx - 50) / (maxWidth),
                                      (details.offset.dy - 50) / (maxHeight)));
                                  print("rateOffsets: ${rateOffsets}");
                                  print("end offset: ${details.offset}");
                                }
                              }
                            });
                          },
                          dragAnchor: DragAnchor.child,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            File img;
                            if (kIsWeb) {
                              img = await _getImageFromDesktop();
                            } else if (Platform.isIOS || Platform.isAndroid) {
                              img = await _getImageFromTablet();
                            } else {
                              img = await _getImageFromDesktop();
                            }
                            if (img != null) {
                              streamController.sink.add(img);
                              convertOffet();
                              print("Image size: ${imagesize}");
                            }
                          },
                          child: Text(
                            "Load",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                        ),
                        RaisedButton(
                          onPressed: () {
                            realOffsets.clear();
                            rateOffsets.clear();
                            setState(() {});
                          },
                          child: Text(
                            "Clear",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Future buildShowDialog(BuildContext context, MapEntry<int, Offset> o) {
    return showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (context) {
          return Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${o.key}"),
                    Text(
                      "real offset: ${num.parse(realOffsets[o.key].dx.toStringAsFixed(2))} - ${num.parse(realOffsets[o.key].dy.toStringAsFixed(2))}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "rate offset: ${num.parse(rateOffsets[o.key].dx.toStringAsFixed(2))} - ${num.parse(rateOffsets[o.key].dy.toStringAsFixed(2))}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Container buildDeskItem() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: Colors.red, width: 1)),
      child: Image.asset("assets/images/desk.png"),
    );
  }
}

class DeskWidget extends StatelessWidget {
  const DeskWidget({
    Key key,
    this.ontap,
    this.onPanUpdate,
    this.onLongPress,
    this.offset,
  }) : super(key: key);
  final Function ontap;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function onLongPress;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: ontap,
        onPanUpdate: onPanUpdate,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.red, width: 0)),
          child: Image.asset("assets/images/desk.png"),
        ),
      ),
    );
  }
}
