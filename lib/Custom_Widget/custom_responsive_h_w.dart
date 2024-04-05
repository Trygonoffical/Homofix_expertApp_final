import 'package:flutter/material.dart';

double getMediaQueryHeight(
    {required BuildContext context, required num value}) {
  var size = MediaQuery.of(context).size;

  double xdHeight = 812;
  double percentage = (value / xdHeight * 100).roundToDouble() / 100;
  // log("height percentage : ${percentage}");
  return size.height * percentage;
}

double getMediaQueryWidth({required BuildContext context, required num value}) {
  var size = MediaQuery.of(context).size;

  double xdWidth = 375;
  double percentage = (value / xdWidth * 100).roundToDouble() / 100;
  // log("width percentage : ${percentage}");
  return size.width * percentage;
}
