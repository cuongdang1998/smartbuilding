part of 'drag_bloc.dart';

@immutable
abstract class DragState {}

class DragInitial extends DragState {}

class DragDeskSuccess extends DragState {
  final List<Offset> deskRateOffset;
  final List<Offset> deskRealOffset;

  DragDeskSuccess({this.deskRateOffset, this.deskRealOffset});
}

class DragDeskFail extends DragState {}

class UpdateDeskOffsetSuccess extends DragState {
  final List<Offset> deskRateOffset;
  final List<Offset> deskRealOffset;

  UpdateDeskOffsetSuccess({this.deskRateOffset, this.deskRealOffset});
}

class DeleteDeskSuccess extends DragState {
  final List<Offset> deskRateOffset;
  final List<Offset> deskRealOffset;

  DeleteDeskSuccess({this.deskRateOffset, this.deskRealOffset});
}

class ClearAllDeskSucces extends DragState{
  final List<Offset> deskRateOffset;
  final List<Offset> deskRealOffset;

  ClearAllDeskSucces({this.deskRateOffset, this.deskRealOffset});

}