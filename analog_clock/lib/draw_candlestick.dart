// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'candlestick.dart';

/// A Candlestick clock that is drawn with [CustomPainter]
///
/// The candlestick's length scales based on the screen's size.
/// This code is used to build the hour, second and minute candlesticks, and demonstrates
/// building a custom Candlestick.
class DrawCandlestick extends Candlestick {
  /// Create a const clock [Candlestick].
  const DrawCandlestick({
    @required Color color,
    @required double candlestickTailLength,
    @required this.type,
    @optionalTypeArgs this.hours,
    @optionalTypeArgs this.minutes,
    @optionalTypeArgs this.seconds,
  })  : assert(color != null),
        assert(type != null),
        assert(candlestickTailLength != null),
        super(
          color: color,
          candlestickTailLength: candlestickTailLength,
        );

  /// Type of Candlestick to be drawn.
  final String type;
  final int hours, minutes, seconds;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _CandlestickPainter(
            color: color,
            type: type,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
            candlestickTailLength: candlestickTailLength,
          ),
        ),
      ),
    );
  }
}

/// [CustomPainter] that draws a Candlestick.
class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    @required this.color,
    @required this.type,
    @required this.candlestickTailLength,
    @optionalTypeArgs this.hours,
    @optionalTypeArgs this.minutes,
    @optionalTypeArgs this.seconds,
  })  : assert(color != null),
        assert(candlestickTailLength != null),
        assert(type != null);

  double sizeToBeModified;
  double candlestickWidth, candlestickTailLength;
  double dx;
  double yStartValue;
  double yEndValue;
  Color color;
  String type;
  int hours, minutes, seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    /****    Y-AXIS Coordinate Calculations   *****/

    final double lowerTailHeight = candlestickTailLength;
    final double upperTailHeight = candlestickTailLength;
    // Considering X-Axis as Reference, calculating the vertical length upto which the candlestick can attain.
    double yCoordinateUpper = upperTailHeight;
    double yCoordinateLower = (height - lowerTailHeight);
    // Calculating the Candlestick length from upper tail tip to the lower tail tip.
    double fullCandlestickHeight = yCoordinateLower - yCoordinateUpper;
    // Calculating the Minute/Second Label gaps with reference to Candlestick
    // Length to make it generalised on different Screen dimensions
    double minuteSecondLabelGap = fullCandlestickHeight / 59;
    // Calculating the Hour Label gaps with reference to Candlestick Length
    double hourLabelGap = fullCandlestickHeight / 11;

    /****    Placement of Candlesticks along X-Axis   *****/

    //Placing of HOUR Reference Axis at One-Tenth position from the left.
    final double hourXCoordinate = 0.1 * width;
    //Placing of MINUTE Reference Axis at Quarter position from the right.
    final double minuteSecondXCoordinate = width - (2.5 * hourXCoordinate);
    // Calculating in the form of Partitions mainly to draw the Candlesticks
    //in a Generalized way to get the best appearance with respect to different Screen sizes.
    // The space within Hour Reference Axis and Minute Reference Axis has been divided into 4 equal Partitions.
    double partition = (minuteSecondXCoordinate - hourXCoordinate) / 4;
    // Setting the width of Candlestick to 70% of the partition
    candlestickWidth = 0.7 * partition;
    // Candlesticks are placed in a symmetrical position therefore placed in partitions.
    // HOUR Candlestick is placed between 1st and 2nd Partition.
    double hourCandlestickPosition =
        hourXCoordinate + partition + (candlestickWidth / 2);
    // MINUTE Candlestick is placed between 3rd and 4th Partition.
    double minuteCandlestickPosition =
        (hourXCoordinate + (partition * 3)) - (candlestickWidth / 2);
    // SECOND Candlestick is placed after MINUTE Reference Axis i.e. exactly in the middle of the 25% section from the Right.
    double secondCandlestickPosition =
        (minuteSecondXCoordinate + (width - minuteSecondXCoordinate) / 2);

    /// AS PER THE CONCEPT of CANDLESTICKS,
    /// GREEN Candlesticks are drawn from bottom to top i.e Open Price is at Bottom and Close Price is at Top thereby representing Profit
    /// RED Candlesticks are drawn from top to bottom i.e Open Price is at Top and Close Price is at Bottom thereby representing Loss
    /// NOTE: Only HOUR Candlestick is represented with GREEN and RED colors depending on the Meridiem (AM/PM)
    /// Setting the Y-Coordinate of HOUR Candlestick as per the conditions of AM or PM
    if (type == "hour") {
      dx = hourCandlestickPosition;
      //Y-Start value set to Lower for Green(AM)/set to Upper for Red (PM)
      yStartValue = (hours < 12) ? yCoordinateLower : yCoordinateUpper;
      //Y-End value set to Upper for Green(AM)/set to Lower for Red (PM)
      yEndValue = (hours < 12) ? yCoordinateUpper : yCoordinateLower;
      //Set a width of 2 to just display 0th Hour in Candlestick
      sizeToBeModified = (hours == 0 || hours == 23)
          ? (hours == 0 ? 2 : ((hours % 12) * hourLabelGap + 2))
          : (hours % 12) * hourLabelGap;
    } else if (type == "minute") {
      dx = minuteCandlestickPosition;
      //Y-Start,End values ALWAYS set to Lower as MINUTE Candlestick is ALWAYS Green in color
      yStartValue = yCoordinateLower;
      yEndValue = yCoordinateUpper;
      //Set a width of 2 to just display Candlestick in 0th Minute
      sizeToBeModified = (minutes == 0) ? 2 : minutes * minuteSecondLabelGap;
    } else if (type == "second") {
      dx = secondCandlestickPosition;
      //Y-Start,End values ALWAYS set to Lower as SECOND Candlestick is ALWAYS Green in color
      yStartValue = yCoordinateLower;
      yEndValue = yCoordinateUpper;
      //Set a width of 2 to just display Candlestick in 0th Second
      sizeToBeModified = (seconds == 0) ? 2 : seconds * minuteSecondLabelGap;
    }

    Offset candlestickTopLeft, tailStart, tailEnd;
    //Calculating Offset for Rectangle/Candlestick's TopLeft, Tail start and end.
    if (yStartValue < yEndValue) {
      //Condition for HOUR(AM), MINUTE, SECOND
      tailStart = Offset(dx, yStartValue - 30);
      candlestickTopLeft = Offset(dx - (candlestickWidth / 2), yStartValue);
      sizeToBeModified = (yEndValue - yStartValue) - sizeToBeModified;
      tailEnd = Offset(dx, yEndValue + 30);
    } else {
      //Condition for HOUR(PM)
      tailStart = Offset(dx, yStartValue + 30);
      candlestickTopLeft =
          Offset(dx - (candlestickWidth / 2), yStartValue - sizeToBeModified);
      tailEnd = Offset(dx, yEndValue - 30);
    }

    final candlestickPaint = Paint()..color = color;

    //Draw Candlestick based on Offset being set
    canvas.drawRect(
        candlestickTopLeft & Size(candlestickWidth, sizeToBeModified),
        candlestickPaint);

    final tailLinePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0;

    //Draw Tail of the Candlestick based on Offsets being set
    canvas.drawLine(tailStart, tailEnd, tailLinePaint);
  }

  @override
  bool shouldRepaint(_CandlestickPainter oldDelegate) {
    return oldDelegate.sizeToBeModified != sizeToBeModified ||
        oldDelegate.candlestickWidth != candlestickWidth ||
        oldDelegate.dx != dx ||
        oldDelegate.yStartValue != yStartValue ||
        oldDelegate.yEndValue != yEndValue ||
        oldDelegate.color != color;
  }
}
