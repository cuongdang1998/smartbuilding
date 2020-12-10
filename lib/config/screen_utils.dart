import 'package:flutter/material.dart';

class ScreenUtils {
  static const Size designSize = Size(1791.0, 1009.0);
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double defaultSize;
  static Orientation orientation;
  static double textScaleFactor;
  bool allowFontScaling = false;

  static void init(BuildContext context, {allowFontScaling = false}) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    textScaleFactor = _mediaQueryData.textScaleFactor;
  }

  double get scaleWidth => (screenWidth / designSize.width);

  double get scaleHeight => (screenHeight / designSize.height);

  double get scaleText => scaleWidth;

  double setHeight(double inputHeight) {
    return inputHeight * scaleHeight;
  }

  double setWidth(double inputWidth) {
    return inputWidth * scaleWidth;
  }

  num setSp(num fontSize, {bool allowFontScalingSelf}) =>
      allowFontScalingSelf == null
          ? (allowFontScaling
              ? (fontSize * scaleText)
              : ((fontSize * scaleText) / textScaleFactor))
          : (allowFontScalingSelf
              ? (fontSize * scaleText)
              : ((fontSize * scaleText) / textScaleFactor));
}
