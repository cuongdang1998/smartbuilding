import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
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
  final _picker = ImagePicker();
  GlobalKey imagekey = GlobalKey();
  GlobalKey deskkey = GlobalKey();
  StreamController streamController = StreamController<File>.broadcast();
  List<Offset> offsets = [];
  Size imagesize;
  Offset offset;
  Future _getImageFromTablet() async {
    final image = await _picker.getImage(source: ImageSource.gallery);
    _image = File(image.path);
    return _image;
  }

  @override
  void initState() {
    super.initState();
  }

  getImageSize() {
    RenderBox render = imagekey.currentContext.findRenderObject();
    imagesize = render.size;
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
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<File>(
            stream: streamController.stream,
            builder: (context, snapshot) {
              // print("snappshot : ${snapshot.data}");
              return Container(
                padding: EdgeInsets.all(50),
                child: Column(
                  children: [
                    Expanded(
                      child: snapshot.hasData
                          ? Container(
                              key: imagekey,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    height: double.infinity,
                                    width: size.width,
                                    child: Image.file(
                                      snapshot.data,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Stack(
                                      clipBehavior: Clip.none,
                                      children:
                                          offsets.asMap().entries.map((o) {
                                        return DeskWidget(
                                          offset: Offset(offsets[o.key].dx,
                                              offsets[o.key].dy),
                                          onPanUpdate: (detail) {
                                            var dx = offsets[o.key].dx +
                                                detail.delta.dx;
                                            var dy = offsets[o.key].dy +
                                                detail.delta.dy;
                                            var maxHeight =
                                                imagesize.height - 50;
                                            var maxWidth = imagesize.width - 50;
                                            print(
                                                "onmove : dx: ${dx} - dy: ${dy} - maxWidth: ${maxWidth} maxHeight: ${maxHeight}");
                                            setState(() {
                                              offsets[o.key] = getOffset(
                                                  dx: dx,
                                                  dy: dy,
                                                  maxHeight: maxHeight,
                                                  maxWidth: maxWidth);
                                            });
                                          },
                                          ontap: () {
                                            print(
                                                "okey: ${o.key} offset: ${offsets[o.key].dx} - ${offsets[o.key].dy}");
                                            // offsets.indexOf(e);
                                          },
                                        );
                                      }).toList())
                                  //   children: [
                                  //     DeskWidget(
                                  //       offset: offset,
                                  //       onPanUpdate: (detail) {
                                  //         var dx = offset.dx + detail.delta.dx;
                                  //         var dy = offset.dy + detail.delta.dy;
                                  //         var maxHeight = imagesize.height - 50;
                                  //         var maxWidth = imagesize.width - 50;
                                  //         print(
                                  //             "onmove : dx: ${dx} - dy: ${dy} - maxWidth: ${maxWidth} maxHeight: ${maxHeight}");
                                  //         setState(() {
                                  //           offset = getOffset(
                                  //               dx: dx,
                                  //               dy: dy,
                                  //               maxHeight: maxHeight,
                                  //               maxWidth: maxWidth);
                                  //         });
                                  //       },
                                  //       ontap: () {
                                  //         print("tap ne");
                                  //       },
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ))
                          : Container(
                              width: size.width,
                              child: GestureDetector(
                                onTap: () async {
                                  if (Platform.isIOS || Platform.isAndroid) {
                                    print("tablet");
                                    streamController.sink
                                        .add(await _getImageFromTablet());
                                    offsets.clear();
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                            (_) => getImageSize());
                                  } else {
                                    print("desktop");
                                    // _getImageFromDesktop();
                                  }
                                },
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
                          /// Use gesture detector
                          // GestureDetector(
                          //     onPanUpdate: (details) {
                          //       setState(() {
                          //         if (snapshot.hasData) {
                          //           if (details.globalPosition >=
                          //                   Offset(50, 50) &&
                          //               details.globalPosition <=
                          //                   Offset(imagesize.width,
                          //                       imagesize.height)) {
                          //             offset = details.globalPosition;
                          //             // offsets.add(offset);
                          //             print(
                          //                 "end offset: ${details.globalPosition}");
                          //           }
                          //         }
                          //       });
                          //     },
                          //     onPanEnd: (end) {
                          //       setState(() {
                          //         offsets.add(offset);
                          //       });
                          //     },
                          //     child: buildDeskItem()),

                          /// Use draggable
                          Draggable(
                            childWhenDragging: buildDeskItem(),
                            child: buildDeskItem(),
                            feedback: buildDeskItem(),
                            onDragEnd: (DraggableDetails details) {
                              setState(() {
                                if (snapshot.hasData) {
                                  if (details.offset >= Offset(50, 50) &&
                                      details.offset <=
                                          Offset(imagesize.width - 50,
                                              imagesize.height - 50)) {
                                    offsets.add(details.offset);
                                    print("end offset: ${details.offset}");
                                  }
                                }
                              });
                            },
                            dragAnchor: DragAnchor.child,
                          ),
                          RaisedButton(
                            onPressed: () async {
                              if (Platform.isIOS || Platform.isAndroid) {
                                print("tablet");
                                streamController.sink
                                    .add(await _getImageFromTablet());
                                offsets.clear();
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => getImageSize());
                              } else {
                                print("desktop");
                                // _getImageFromDesktop();
                              }
                              print("size target ${imagesize}");
                            },
                            child: Text(
                              "Load",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.blue,
                          ),
                          RaisedButton(
                            onPressed: () async {
                              offsets.clear();
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
      ),
    );
  }

  Container buildDeskItem() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: Colors.red, width: 2)),
      child: Image.asset("assets/images/desk.png"),
    );
  }
}

class DeskWidget extends StatelessWidget {
  const DeskWidget({
    Key key,
    this.ontap,
    this.onPanUpdate,
    this.offset,
  }) : super(key: key);
  final Offset offset;
  final Function ontap;
  final Function(DragUpdateDetails) onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: GestureDetector(
        onTap: ontap,
        onPanUpdate: onPanUpdate,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.red, width: 2)),
          child: Image.asset("assets/images/desk.png"),
        ),
      ),
    );
  }
}

class DraggableWidget extends StatelessWidget {
  final Offset offset;

  DraggableWidget({Key key, this.offset}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Draggable(
      childWhenDragging: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.red, width: 2)),
        child: Image.asset("assets/images/desk.png"),
      ),
      feedback: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.red, width: 2)),
        child: Image.asset("assets/images/desk.png"),
      ),
      onDragEnd: (details) {},
    );
  }
}
