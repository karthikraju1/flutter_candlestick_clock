// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// A base class for an analog clock hand-drawing widget.
///
/// This only draws one hand of the analog clock. Put it in a [Stack] to have
/// more than one hand.
abstract class Candlestick extends StatelessWidget {
  /// Create a const clock [Hand].
  ///
  /// All of the parameters are required and must not be null.
  const Candlestick({
    @required this.color,
    @required this.candlestickTailLength,
  })  : assert(color != null),
        assert(candlestickTailLength != null);

  final Color color;                      // Candlestick color.
  final double candlestickTailLength;     // Candlestick Tail Length (Taken as a reference to draw the entire Candlestick).
}
