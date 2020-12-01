import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:mime/mime.dart';

part 'upload_image_event.dart';
part 'upload_image_state.dart';

class UploadImageBloc extends Bloc<UploadImageEvent, UploadImageState> {
  UploadImageBloc() : super(UploadImageInitial());
  List<Offset> rateOffsets = [
    Offset(1 / 5, 2 / 3),
    Offset(1 / 3, 2 / 9),
    Offset(1 / 10, 1 / 2),
    Offset(1 / 5, 11 / 20),
    Offset(2 / 3, 5 / 6),
    Offset(5 / 9, 3 / 10),
    Offset(2 / 9, 13 / 21),
    Offset(13 / 29, 13 / 20),
    Offset(1, 1),
  ];
  List<Offset> realOffsets = [];
  bool isImage(String path) {
    final mimeType = lookupMimeType(path);
    if (mimeType?.startsWith('image/') == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<File> _getImageFromTablet() async {
    File _image;
    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image != null) {
      _image = File(image?.path);
    }
    return _image;
  }

  Future _getImageFromDesktop() async {
    File _image;
    try {
      FilePickerCross file =
          await FilePickerCross.importFromStorage(type: FileTypeCross.image);
      print("======= hey:${isImage(file.path)}");
      if (isImage(file.path)) {
        _image = File(file?.path);
        return _image;
      } else {
        return null;
      }
    } catch (ex) {
      print(ex.toString());
    }
  }

  @override
  Stream<UploadImageState> mapEventToState(
    UploadImageEvent event,
  ) async* {
    if (event is UploadImage) {
      File img;
      if (kIsWeb) {
        img = await _getImageFromDesktop();
      } else if (Platform.isIOS || Platform.isAndroid) {
        img = await _getImageFromTablet();
      } else {
        img = await _getImageFromDesktop();
      }
      if (img != null) {
        yield UploadImageSuccess(image: img);
      } else {
        yield UploadImageFail();
      }
    }
    if (event is FetchAllItem) {
      // Convert from rate offset to real offset
      realOffsets = rateOffsets
          .map((e) => Offset(
              e.dx * (event.imageSize.width), e.dy * (event.imageSize.height)))
          .toList();
      print("image size in FetchDeskEvent ${event.imageSize}");
      yield FetchAllItemSuccess(
          rateDeskOffset: rateOffsets, realDeskOffset: realOffsets);
    }
  }
}
