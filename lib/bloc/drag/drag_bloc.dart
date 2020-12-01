import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'drag_event.dart';
part 'drag_state.dart';

class DragBloc extends Bloc<DragEvent, DragState> {
  DragBloc() : super(DragInitial());
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
  Stream<DragState> mapEventToState(
    DragEvent event,
  ) async* {
    if (event is DragDeskEvent) {
      if (event.image != null) {
        if (event.offset >= Offset(event.marginLeft, event.marginTop) &&
            event.offset <=
                Offset(
                    event.imageSize.width +
                        event.marginLeft -
                        event.deskSize.width,
                    event.imageSize.height +
                        event.marginTop -
                        event.deskSize.height)) {
          // Add offset to real offset list
          //Must delete Offset(event.marginLeft, event.marginTop) because padding(top: marginTop, lef: marginLeft)
          event.deskRealOffset
              .add(event.offset - Offset(event.marginLeft, event.marginTop));
          print("deskRealOffsets: ${event.deskRealOffset}");
          event.deskRateOffset.add(Offset(
              (event.offset.dx - event.marginLeft) /
                  (event.imageSize.width - event.deskSize.width),
              (event.offset.dy - event.marginTop) /
                  (event.imageSize.height - event.deskSize.height)));
          print("rateOffsets: ${event.deskRateOffset}");
          print("end offset: ${event.offset}");
          yield DragDeskSuccess(
              deskRealOffset: event.deskRealOffset,
              deskRateOffset: event.deskRateOffset);
        }
      } else {
        yield DragDeskFail();
      }
    }
    if (event is UpdateDeskOffsetEvent) {
      var dx = event.deskRealOffset[event.index].dx + event.detail.delta.dx;
      var dy = event.deskRealOffset[event.index].dy + event.detail.delta.dy;
      print(
          "event.deskRealOffset[event.index].dx: ${event.deskRealOffset[event.index].dx}onmove : dx: ${dx} - dy: ${dy} - maxWidth: ${event.maxWidth} maxHeight: ${event.maxHeight}");
      var offset = getOffset(
        dx: dx,
        dy: dy,
        maxWidth: event.maxWidth,
        maxHeight: event.maxHeight,
      );
      event.deskRealOffset[event.index] = offset;
      event.deskRateOffset[event.index] =
          Offset(offset.dx / event.maxWidth, offset.dy / event.maxHeight);
      yield UpdateDeskOffsetSuccess(
          deskRealOffset: event.deskRealOffset,
          deskRateOffset: event.deskRateOffset);
    }
    if (event is DeleteDeskEvent) {
      event.deskRateOffset.removeAt(event.index);
      event.deskRealOffset.removeAt(event.index);
      yield DeleteDeskSuccess(
          deskRealOffset: event.deskRealOffset,
          deskRateOffset: event.deskRateOffset);
    }
    if (event is ClearAllDeskEvent) {
      event.deskRateOffset.clear();
      print("${event.deskRateOffset}");
      event.deskRealOffset.clear();
      print("${event.deskRealOffset}");
      yield ClearAllDeskSucces(
          deskRateOffset: event.deskRateOffset,
          deskRealOffset: event.deskRealOffset);
    }
  }
}
