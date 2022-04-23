import 'dart:async';

import 'package:flutter/material.dart';

class LiveTimePlot extends StatefulWidget {
  const LiveTimePlot({
    Key? key,
    this.count = 500,
    this.period = 10,
    this.values = const <int>{},
  }) : super(key: key);

  /// count of ticks
  final int count;

  /// plot width in seconds
  final int period;

  /// values as unixtime in ms
  final Set<int> values;

  @override
  State<LiveTimePlot> createState() => _LiveTimePlotState();
}

class _LiveTimePlotState extends State<LiveTimePlot> {
  @override
  void didUpdateWidget(covariant LiveTimePlot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.values.isNotEmpty && oldWidget.values.isEmpty) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {});
        }
      });
    }

    return TimePlot(
      unixTime: DateTime.now().millisecondsSinceEpoch,
      period: widget.period,
      count: widget.count,
      values: widget.values,
    );
  }
}

class TimePlot extends StatelessWidget {
  const TimePlot({
    Key? key,
    this.count = 500,
    this.period = 10,
    required this.unixTime,
    this.values = const <int>{},
  }) : super(key: key);

  /// count of ticks
  final int count;

  /// plot width in seconds
  final int period;

  /// current unixtime ms
  final int unixTime;

  /// values as unixtime in ms
  final Set<int> values;

  @override
  Widget build(BuildContext context) {
    final Set<int> recalculatedValues = values
        .map((int tickTime) => count - (unixTime - tickTime) * count / 1000 ~/ period)
        .map((int value) {
          if (value < 0 || value > count - 1) {
            return null;
          }

          return value;
        })
        .whereType<int>()
        .toSet();

    return SimplePlot(
      count: count,
      values: recalculatedValues,
    );
  }
}

class SimplePlot extends StatelessWidget {
  const SimplePlot({
    Key? key,
    this.count = 500,
    this.values = const <int>{},
  }) : super(key: key);

  /// count of ticks
  final int count;

  /// ticks to set
  final Set<int> values;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _getTicks(),
    );
  }

  List<Widget> _getTicks() {
    return Iterable<Widget>.generate(
      count,
      (int index) {
        return Expanded(
          child: values.contains(index)
              ? Container(
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.blue.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.blue.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                ),
        );
      },
    ).toList();
  }
}
