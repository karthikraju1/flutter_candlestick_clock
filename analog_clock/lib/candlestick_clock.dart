// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Author: V Karthik Raju

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

import 'draw_labels.dart';
import 'draw_candlestick.dart';

/// Candlestick clock.
class CandlestickClock extends StatefulWidget {
  const CandlestickClock(this.model);

  final ClockModel model;

  @override
  _CandlestickClockState createState() => _CandlestickClockState();
}

class _CandlestickClockState extends State<
        CandlestickClock> //SingleTickerProviderStateMixin for AnimationController implementation
    with
        SingleTickerProviderStateMixin {
  var _now = DateTime.now();
  Timer _timer;
  AnimationController _controller;

  // TweenSequence for background colors to be changed in an animated fashion for the entire day.
  Animatable<Color> background = TweenSequence<Color>(
    [
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Color(0xFF212121),
          end: Color(0xFF757575),
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Color(0xFFD6D6D6),
          end: Color(0xFFFAFAFA),
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Color(0xFFFAFAFA),
          end: Color(0xFFD6D6D6),
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Color(0xFF757575),
          end: Color(0xFF212121),
        ),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    // AnimationController object initialized with the duration of entire day.
    _controller = AnimationController(
      duration: const Duration(seconds: 86400),
      vsync: this,
    )..repeat();

    _updateTime();
  }

  @override
  void didUpdateWidget(CandlestickClock oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Custom Theme for colors of 2 types of Candlesticks
    final customTheme = Theme.of(context).copyWith(
      primaryColor: Colors.green,
      accentColor: Colors.red,
      highlightColor: Colors.blueAccent,
      dividerColor: Colors.grey,
    );

    final time = DateFormat.Hms().format(DateTime.now());

    //Setting the setter 'value' of AnimationController object (within the range 0.0 to 1.0)
    // as per the number of seconds elapsed as of now for the entire day
    // in order to set the appropriate background color.
    _controller.value = (_now.second == 0)
        ? (1 / 86400) *
            (((_now.hour) * 60 * 60) + (((_now.minute - 1) * 60) + 1))
        : (1 / 86400) * (((_now.hour) * 60 * 60) + (_now.minute * _now.second));

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Candlestick clock with time $time',
        value: time,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Scaffold(
            body: Container(
              color: background
                  .evaluate(AlwaysStoppedAnimation(_controller.value)),
              child: Stack(
                children: [
                  // Reference Axis for HOURS with Labels(with current HOUR Highlighted)
                  // along with the background Reference Horizontal Lines drawn with [CustomPainter].
                  // Labels 0-11 with a difference of 1 are added on the axis
                  DrawLabels(
                    firstValue: 0,
                    lastValue: 11,
                    color: customTheme.dividerColor,
                    type: "hourLabel",
                    candlestickTailLength: 40.0,
                    hourHighlightColor: customTheme.highlightColor,
                    hourToBeHighlighted: _now.hour % 12,
                    meridiem: (_now.hour < 12) ? "AM" : "PM",
                  ),
                  // Common Reference Axis for MINUTES and SECONDS with Labels(also with current MINUTE highlighted) [CustomPainter].
                  // Labels 0-55 with a difference of 5 are added on the axis, 59 is excluded though to maintain symmetry of the Labels
                  DrawLabels(
                    firstValue: 0,
                    lastValue: 59,
                    color: customTheme.dividerColor,
                    type: "minuteSecondLabel",
                    candlestickTailLength: 40.0,
                    minuteHighlightColor: customTheme.highlightColor,
                    secondHightlightColor: customTheme.accentColor,
                    minuteToBeHighlighted: _now.minute,
                    secondToBeHighlighted: _now.second,
                  ),
                  // SECOND Candlestick drawn with [CustomPainter].
                  DrawCandlestick(
                    //SECOND Candlestick ALWAYS stay GREEN colored
                    color: customTheme.primaryColor,
                    type: "second",
                    seconds: _now.second,
                    candlestickTailLength: 40.0,
                  ),
                  // MINUTE Candlestick drawn with [CustomPainter].
                  DrawCandlestick(
                    //MINUTE Candlestick ALWAYS stay GREEN colored
                    color: customTheme.primaryColor,
                    type: "minute",
                    minutes: _now.minute,
                    candlestickTailLength: 40.0,
                  ),
                  // HOUR Candlestick drawn with [CustomPainter].
                  DrawCandlestick(
                    //GREEN colored HOUR Candlestick represents AM i.e. first half of the day
                    //RED colored HOUR Candlestick represents PM i.e. second half of the day
                    color: (_now.hour < 12)
                        ? customTheme.primaryColor
                        : customTheme.accentColor,
                    type: "hour",
                    hours: _now.hour,
                    candlestickTailLength: 40.0,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
