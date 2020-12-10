import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_building/bloc/drag/drag_bloc.dart';
import 'package:smart_building/bloc/load_image/upload_image_bloc.dart';
import 'package:smart_building/config/screen_utils.dart';

class DraggableScreen extends StatefulWidget {
  @override
  _DraggableScreenState createState() => _DraggableScreenState();
}

class _DraggableScreenState extends State<DraggableScreen> {
  File _image;

  Size imageSize;

  Size deskSize;

  double maxWidth;

  double maxHeight;

  GlobalKey imageKey = GlobalKey();

  GlobalKey deskKey = GlobalKey();

  GlobalKey singleSensorKey = GlobalKey();

  GlobalKey sensorSetKey = GlobalKey();

  List<Offset> deskRateOffsets = [];

  List<Offset> deskRealOffsets = [];

  StreamController<Size> streamController = StreamController<Size>();

  getImageSize() {
    RenderBox deskRender = deskKey?.currentContext?.findRenderObject();
    deskSize = deskRender?.size ?? deskSize;
    RenderBox imageRender = imageKey.currentContext.findRenderObject();
    imageSize = imageRender.size;
    streamController.sink.add(imageSize);
    maxWidth = imageSize.width - deskSize.width;
    maxHeight = imageSize.height - deskSize.height;
    //print("deskSize: ${deskSize} imageSize: ${imageSize}");
    convertOffet();
  }

  convertOffet() {
    deskRealOffsets = deskRateOffsets
        .map((e) => Offset(e.dx * (maxWidth), e.dy * (maxHeight)))
        .toList();
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    developer.log("trigger build");
    ScreenUtils.init(context);
    return StreamBuilder<Size>(
        stream: streamController.stream,
        builder: (context, snapshot) {
          return BlocConsumer<UploadImageBloc, UploadImageState>(
              listener: (context, state) {
            if (state is UploadImageSuccess) {
              _image = state.image;
              // BlocProvider.of<UploadImageBloc>(context)
              //     .add(FetchAllItem(imageSize: Size(maxWidth, maxHeight)));
              context
                  .read<UploadImageBloc>()
                  .add(FetchAllItem(imageSize: Size(maxWidth, maxHeight)));
            }
            if (state is UploadImageFail) {
              print("Buon qua!");
            }
            if (state is FetchAllItemSuccess) {
              print("Ok Anh Cuong");
              deskRealOffsets = state.realDeskOffset;
              deskRateOffsets = state.rateDeskOffset;
            }
          }, builder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) => getImageSize());
            return Scaffold(
                body: Container(
              padding: EdgeInsets.all(50),
              child: Column(children: [
                Expanded(
                  key: imageKey,
                  child: _image != null
                      ? Container(
                          child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: double.infinity,
                              width: size.width,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.red, width: 2)),
                              child: Image.file(
                                _image,
                                fit: BoxFit.fill,
                              ),
                            ),
                            BlocConsumer<DragBloc, DragState>(
                                listener: (context, state) {
                              if (state is DragDeskSuccess) {
                                deskRealOffsets = state.deskRealOffset;
                                deskRateOffsets = state.deskRateOffset;
                              }
                              if (state is UpdateDeskOffsetSuccess) {
                                deskRealOffsets = state.deskRealOffset;
                                deskRateOffsets = state.deskRateOffset;
                              }
                              if (state is DeleteDeskSuccess) {
                                deskRealOffsets = state.deskRealOffset;
                                deskRateOffsets = state.deskRateOffset;
                              }
                            }, builder: (context, state) {
                              return Stack(clipBehavior: Clip.none, children: [
                                ...deskRealOffsets.asMap().entries.map((o) {
                                  return DeskWidget(
                                    offset: o.value,
                                    onPanUpdate: (detail) {
                                      BlocProvider.of<DragBloc>(context).add(
                                          UpdateDeskOffsetEvent(
                                              deskRateOffset: deskRateOffsets,
                                              deskRealOffset: deskRealOffsets,
                                              maxWidth: maxWidth,
                                              maxHeight: maxHeight,
                                              detail: detail,
                                              index: o.key));
                                    },
                                    ontap: () {
                                      print(
                                          "okey: ${o.key} offset: ${deskRealOffsets[o.key].dx} - ${deskRealOffsets[o.key].dy}");
                                      buildShowDialog(context, o);
                                    },
                                    onLongPress: () {
                                      BlocProvider.of<DragBloc>(context).add(
                                          DeleteDeskEvent(
                                              index: o.key,
                                              deskRealOffset: deskRealOffsets,
                                              deskRateOffset: deskRateOffsets));
                                    },
                                  );
                                }).toList(),
                              ]);
                            }),
                          ],
                        ))
                      : Container(
                          width: size.width,
                          child: GestureDetector(
                            onTap: () async {},
                            child: Container(
                              child: Icon(
                                Icons.image,
                                size: ScreenUtils().setWidth(300),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      /// Sensor set draggable
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Draggable(
                            childWhenDragging: buildSensorSetItem(),
                            child: Container(
                                key: sensorSetKey, child: buildSensorSetItem()),
                            feedback: buildSensorSetItem(),
                            onDragEnd: (DraggableDetails details) {
                              developer.log('build details ${details.offset}',
                                  name: 'Main');
                            },
                            dragAnchor: DragAnchor.child,
                          ),
                          Text("Single Sensor"),
                        ],
                      ),

                      /// Single sensor draggable
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Draggable(
                            childWhenDragging: buildSingleSensorItem(),
                            child: Container(
                                key: singleSensorKey,
                                child: buildSingleSensorItem()),
                            feedback: buildSingleSensorItem(),
                            onDragEnd: (DraggableDetails details) {
                              developer.log('build details ${details.offset}',
                                  name: 'Main');
                            },
                            dragAnchor: DragAnchor.child,
                          ),
                          Text("Single Sensor"),
                        ],
                      ),

                      /// Desk draggable
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Draggable(
                            childWhenDragging: buildDeskItem(),
                            child:
                                Container(key: deskKey, child: buildDeskItem()),
                            feedback: buildDeskItem(),
                            onDragEnd: (DraggableDetails details) {
                              developer.log('build details ${details.offset}',
                                  name: 'Main');
                              // BlocProvider.of<DragBloc>(context).add(DragDeskEvent(
                              //     image: _image,
                              //     deskRateOffset: deskRateOffsets,
                              //     deskRealOffset: deskRealOffsets,
                              //     offset: details.offset,
                              //     imageSize: imageSize,
                              //     marginLeft: 50,
                              //     marginTop: 50));
                              context.read<DragBloc>().add(DragDeskEvent(
                                  image: _image,
                                  deskRateOffset: deskRateOffsets,
                                  deskRealOffset: deskRealOffsets,
                                  offset: details.offset,
                                  imageSize: imageSize,
                                  deskSize: deskSize,
                                  marginLeft: 50,
                                  marginTop: 50));
                            },
                            dragAnchor: DragAnchor.child,
                          ),
                          Text("Desk"),
                        ],
                      ),

                      ///Radius size setting
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                            color: Color(0xff00FF57), shape: BoxShape.circle),
                      ),

                      /// Upload image
                      RaisedButton(
                        onPressed: () async {
                          // BlocProvider.of<UploadImageBloc>(context)
                          //     .add(UploadImage());
                          context.read<UploadImageBloc>().add(UploadImage());
                          print("Image size: ${imageSize}");
                        },
                        child: Text(
                          "Load",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blue,
                      ),

                      /// Clear all items
                      RaisedButton(
                        onPressed: () {
                          // BlocProvider.of<DragBloc>(context).add(ClearAllDeskEvent(
                          //     deskRealOffset: deskRealOffsets,
                          //     deskRateOffset: deskRateOffsets));
                          context.read<DragBloc>().add(ClearAllDeskEvent(
                              deskRealOffset: deskRealOffsets,
                              deskRateOffset: deskRateOffsets));
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
              ]),
            ));
          });
        });
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
                      "real offset: ${num.parse(deskRealOffsets[o.key].dx.toStringAsFixed(2))} - ${num.parse(deskRealOffsets[o.key].dy.toStringAsFixed(2))}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "rate offset: ${num.parse(deskRateOffsets[o.key].dx.toStringAsFixed(2))} - ${num.parse(deskRateOffsets[o.key].dy.toStringAsFixed(2))}",
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
      width: 68,
      height: 51,
      decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: Colors.red, width: 1)),
      child: Image.asset(
        "assets/images/desk.png",
        // fit: BoxFit.cover,
      ),
    );
  }

  Container buildSingleSensorItem() {
    return Container(
      height: 31,
      width: 31,
      // decoration:
      //     BoxDecoration(border: Border.all(color: Colors.red, width: 1)),
      child: Image.asset(
        "assets/images/sensorsingle.png",
      ),
    );
  }

  Container buildSensorSetItem() {
    return Container(
      width: 81,
      height: 47,
      // decoration:
      //     BoxDecoration(border: Border.all(color: Colors.red, width: 1)),
      child: Image.asset("assets/images/sensorset.png"),
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
          width: 68,
          height: 51,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.red, width: 1)),
          child: Image.asset(
            "assets/images/desk.png",
            // fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
