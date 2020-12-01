part of 'upload_image_bloc.dart';

@immutable
abstract class UploadImageState {}

class UploadImageInitial extends UploadImageState {}

class UploadImageSuccess extends UploadImageState {
  final File image;

  UploadImageSuccess({this.image});
}

class UploadImageFail extends UploadImageState {}

class FetchAllItemSuccess extends UploadImageState {
  final List<Offset> rateDeskOffset;
  final List<Offset> realDeskOffset;

  FetchAllItemSuccess({this.rateDeskOffset, this.realDeskOffset});
}
