part of 'upload_image_bloc.dart';

abstract class UploadImageEvent {}

class UploadImage extends UploadImageEvent {}

class FetchAllItem extends UploadImageEvent {
  final Size imageSize;

  FetchAllItem({this.imageSize});
}
