part of 'drag_bloc.dart';

@immutable
abstract class DragEvent {}

class DragDeskEvent extends DragEvent {
  final File image;
  final Offset offset;
  final double marginTop;
  final double marginLeft;
  final List<Offset> deskRateOffset;
  final List<Offset> deskRealOffset;
  final Size imageSize;
  final Size deskSize;

  DragDeskEvent({
    this.deskSize,
    this.marginTop,
    this.marginLeft,
    this.imageSize,
    this.image,
    this.deskRateOffset,
    this.deskRealOffset,
    this.offset,
  });
}

class UpdateDeskOffsetEvent extends DragEvent {
  final int index;
  final double maxWidth;
  final double maxHeight;
  final DragUpdateDetails detail;
  final List<Offset> deskRateOffset;
  final List<Offset> deskRealOffset;

  UpdateDeskOffsetEvent(
      {this.maxWidth,
      this.maxHeight,
      this.index,
      this.detail,
      this.deskRateOffset,
      this.deskRealOffset});
}

class DeleteDeskEvent extends DragEvent {
  final List<Offset> deskRateOffset;
  final List<Offset> deskRealOffset;
  final int index;

  DeleteDeskEvent({this.deskRateOffset, this.deskRealOffset, this.index});
}

class ClearAllDeskEvent extends DragEvent {
  final List<Offset> deskRateOffset;
  final List<Offset> deskRealOffset;

  ClearAllDeskEvent({this.deskRateOffset, this.deskRealOffset});
}
