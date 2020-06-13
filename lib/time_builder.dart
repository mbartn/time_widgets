import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:quiver/async.dart';

class TimeBuilder extends StatefulWidget {
  final Function(Duration durationLeft) builder;
  final Function onReachedBuilder;
  final DateTime reachDate;
  final Function() onReachedCallback;

  const TimeBuilder({
    Key key,
    @required this.builder,
    @required this.onReachedBuilder,
    @required this.reachDate,
    this.onReachedCallback,
  }) : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<TimeBuilder> {
  StreamSubscription<CountdownTimer> stream;
  Widget child;

  @override
  void initState() {
    var durationLeft = calculateDifference();
    if (durationLeft.isNegative) {
      child = widget.onReachedBuilder();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onReachedCallback?.call());
    } else {
      child = widget.builder(durationLeft);
      runTimer(durationLeft);
    }
    super.initState();
  }

  @override
  void dispose() {
    stream?.cancel();
    super.dispose();
  }

  Duration calculateDifference() {
    var now = DateTime.now();
/*    DateTime dateToReach = DateTime(
        now.year,
        now.month,
        now.day,
        widget.reachDate.hour,
        widget.reachDate.minute,
        widget.reachDate.second);*/

    return widget.reachDate.difference(now);
  }

  runTimer(Duration durationLeft) {
    stream =
        CountdownTimer(durationLeft, Duration(seconds: 1)).listen((data) {});

    stream.onData((data) {
      print("setting data! ${data.remaining}");
      setState(() {
        child = widget
            .builder(data.remaining.isNegative ? Duration() : data.remaining);
      });
    });
    stream.onDone(() {
      widget.onReachedCallback?.call();
      stream?.cancel();
      stream = null;
      setState(() {
        child = widget.onReachedBuilder();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return child ?? Container();
  }
}
