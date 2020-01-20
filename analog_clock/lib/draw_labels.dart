import 'package:flutter/material.dart';

/// A Reference Axis with Label that is drawn with [CustomPainter]
///
/// The 'Reference Axis along with label' scales based on the screen's size.
/// This code is used to build a reference axis for hour OR a common reference
/// axis for second and minute.

class DrawLabels extends StatelessWidget {
  /// Create a const Reference Axis with Label.
  const DrawLabels({
    @required this.color,
    @required this.firstValue,
    @required this.lastValue,
    @required this.type,
    @required this.candlestickTailLength,
    @optionalTypeArgs this.meridiem,
    @optionalTypeArgs this.hourHighlightColor,
    @optionalTypeArgs this.minuteHighlightColor,
    @optionalTypeArgs this.secondHightlightColor,
    @optionalTypeArgs this.hourToBeHighlighted,
    @optionalTypeArgs this.minuteToBeHighlighted,
    @optionalTypeArgs this.secondToBeHighlighted,
  })  : assert(firstValue != null),
        assert(lastValue != null),
        assert(type != null),
        assert(candlestickTailLength != null),
        assert(color != null);

  final int firstValue,
      lastValue,
      hourToBeHighlighted,
      minuteToBeHighlighted,
      secondToBeHighlighted;
  final Color color,
      hourHighlightColor,
      minuteHighlightColor,
      secondHightlightColor;
  final String meridiem, type;
  final double candlestickTailLength;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _LabelPainter(
            firstValue: this.firstValue,
            lastValue: this.lastValue,
            meridiem: this.meridiem,
            type: this.type,
            color: this.color,
            candlestickTailLength: this.candlestickTailLength,
            hourHighlightColor: this.hourHighlightColor,
            minuteHighlightColor: this.minuteHighlightColor,
            secondHightlightColor: this.secondHightlightColor,
            hourToBeHighlighted: this.hourToBeHighlighted,
            minuteToBeHighlighted: this.minuteToBeHighlighted,
            secondToBeHighlighted: this.secondToBeHighlighted,
          ),
        ),
      ),
    );
  }
}

class _LabelPainter extends CustomPainter {
  _LabelPainter({
    @required this.firstValue,
    @required this.lastValue,
    @required this.color,
    @required this.type,
    @required this.candlestickTailLength,
    @optionalTypeArgs this.hourHighlightColor,
    @optionalTypeArgs this.minuteHighlightColor,
    @optionalTypeArgs this.secondHightlightColor,
    @optionalTypeArgs this.meridiem,
    @optionalTypeArgs this.hourToBeHighlighted,
    @optionalTypeArgs this.minuteToBeHighlighted,
    @optionalTypeArgs this.secondToBeHighlighted,
  })  : assert(firstValue != null),
        assert(lastValue != null),
        assert(color != null),
        assert(type != null),
        assert(candlestickTailLength != null);

  double labelGap, xPosition, candlestickTailLength;
  int firstValue,
      lastValue,
      hourToBeHighlighted,
      minuteToBeHighlighted,
      secondToBeHighlighted;
  Color color, hourHighlightColor, minuteHighlightColor, secondHightlightColor;
  final String meridiem, type;

  @override
  void paint(Canvas canvas, Size size) {
    /*ADD COMMENTS HERE*/

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

    if (type == "hourLabel") {
      xPosition =
          hourXCoordinate; //Setting the X-coordinate of HOUR Reference Axis
      labelGap = hourLabelGap;
    } else if (type == "minuteSecondLabel") {
      xPosition =
          minuteSecondXCoordinate; //Setting the X-coordinate of Common Reference Axis of Minute and Second
      labelGap = minuteSecondLabelGap;
    }

    /// Setting Offsets of endpoints of Reference axis along with fontsize of Labels
    /// considering partition to generalize the font sizes of labels across different screen dimensionns
    Offset start = Offset(xPosition, yCoordinateLower + 30);
    Offset end = Offset(xPosition, yCoordinateUpper - 30);
    double highlightFontSize = 0.6 * partition;
    double referenceLabelFontSize = 0.2 * highlightFontSize;

    final labelLinePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0;

    //Draws Reference axis only
    canvas.drawLine(start, end, labelLinePaint);

    TextSpan span;
    TextPainter tp;
    double yValue = yCoordinateLower;
    double finalXPosition, finalYPosition;
    final highlightPointerColor = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final linesColorPaint = Paint()
      ..color = color
      ..strokeWidth = 0.2;

    if (lastValue == 59) {
      /// CONDITION for adding Labels on Common Reference Axis of MINUTE and SECOND
      for (int i = firstValue; i <= lastValue; i++, yValue -= labelGap) {
        /*********************************************************************************
         *
         * This Section is for adding All Label values beside MINUTE/SECOND Reference Axis
         *
         *********************************************************************************/
        if (i % 5 == 0) {
          // Only SECOND values with difference of 5 will be displayed on the axis
          finalXPosition = xPosition + 5;
          if (i == secondToBeHighlighted) {
            // Current SECOND to be Highlighted in a different color
            span = new TextSpan(
                style: new TextStyle(
                    color: secondHightlightColor,
                    fontSize: referenceLabelFontSize),
                text: '$i');
          } else {
            // Normal SECOND value with general color
            span = new TextSpan(
                style: new TextStyle(
                    color: color, fontSize: referenceLabelFontSize),
                text: '$i');
          }
          tp = new TextPainter(
              text: span,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left);
          tp.layout();
          tp.paint(canvas, new Offset(finalXPosition, yValue - 5));
        }
        /***************************************************************************************************
         *
         * This Section is JUST for highlighting CURRENT MINUTE Label on Left side of Minute Reference Axis
         *
         ***************************************************************************************************/

        if (i == minuteToBeHighlighted) {
          // Current MINUTE to be Highlighted in a different color
          // Padding zeros to the left to display Current MINUTE in 2 digits
          String highlightedMinute = i.toString().padLeft(2, '0');
          span = new TextSpan(
              style: new TextStyle(
                  color: minuteHighlightColor, fontSize: highlightFontSize),
              text: highlightedMinute);

          // Positioning of Labels on Axis with some adjustments like considering percentage of FontSize
          // to make it seamlessly work across devices with different dimensions
          finalXPosition = xPosition - (1.3 * highlightFontSize);
          finalYPosition = yValue - (highlightFontSize / 2);
          tp = new TextPainter(
              text: span,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left);
          tp.layout();
          tp.paint(canvas, new Offset(finalXPosition, finalYPosition));

          // Horizontal Pointer Line of length: 10 highlighting the MINUTE value pointing to the axis
          canvas.drawLine(
              Offset(xPosition - 10, yValue),
              Offset(xPosition, yValue), highlightPointerColor);
        }
      }
    } else {
      /// CONDITION for adding Labels on Reference Axis of Hour
      for (int i = firstValue; i <= lastValue; i++, yValue -= labelGap) {
        /************************************************************************************************
         *
         * This Section is JUST for highlighting CURRENT HOUR Label on Right side of Hour Reference Axis
         *
         ************************************************************************************************/
        if (i == hourToBeHighlighted) {
          int highlightedValue;
          // Condition to display 12 at 12PM instead of 0(as per the normal Loop Logic of 0-11)
          if (meridiem == "PM" && i == 0)
            highlightedValue = 12;
          else
            highlightedValue = i;

          // Padding zeros to the left to display Current HOUR in 2 digits
          String highlightedHour = highlightedValue.toString().padLeft(2, '0');
          span = new TextSpan(
              style: new TextStyle(
                  color: hourHighlightColor, fontSize: highlightFontSize),
              text: highlightedHour);

          // Positioning of Labels on Axis with some adjustments like considering FontSize
          // to make it seamlessly work across devices with different dimensions
          finalXPosition = xPosition + 10;
          finalYPosition = yValue - (highlightFontSize / 2);
          tp = new TextPainter(
              text: span,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left);
          tp.layout();
          tp.paint(canvas, new Offset(finalXPosition, finalYPosition));

          // Horizontal Pointer Line of length: 10 highlighting the HOUR value pointing to the axis
          canvas.drawLine(
              Offset(xPosition, yValue),
              Offset(xPosition + 10, yValue), highlightPointerColor);
        }

        /*****************************************************************************
         *
         * This Section is for adding All Label values beside HOUR Reference Axis
         *
         *****************************************************************************/

        span = new TextSpan(
            style:
                new TextStyle(color: color, fontSize: referenceLabelFontSize),
            text: '$i');
        tp = new TextPainter(
            text: span,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left);
        tp.layout();
        tp.paint(canvas, new Offset(xPosition - (0.3 * highlightFontSize), yValue - 5));

        /// Horizontal Lines drawn on the BACKGROUND all the way from extreme Left of the screen
        /// to the extreme Right by taking HOUR Axis as Reference
        canvas.drawLine(
            Offset(0, yValue),
            Offset(width, yValue), linesColorPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_LabelPainter oldDelegate) {
    return oldDelegate.xPosition != xPosition ||
        oldDelegate.color != color ||
        oldDelegate.hourHighlightColor != hourHighlightColor ||
        oldDelegate.minuteHighlightColor != minuteHighlightColor ||
        oldDelegate.secondHightlightColor != secondHightlightColor ||
        oldDelegate.meridiem != meridiem ||
        oldDelegate.minuteToBeHighlighted != minuteToBeHighlighted ||
        oldDelegate.secondToBeHighlighted != secondToBeHighlighted ||
        oldDelegate.firstValue != firstValue ||
        oldDelegate.lastValue != lastValue;
  }
}
