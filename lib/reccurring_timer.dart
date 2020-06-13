import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:quiver/async.dart';

class RecurringTimer extends StatefulWidget {
  final Function(Duration durationLeft) builder;
  final DateTime reachDate;
  final Duration recurrencePeriod;
  final Function() onReached;

  const RecurringTimer({
    Key key,
    @required this.builder,
    @required this.recurrencePeriod,
    this.reachDate,
    this.onReached,
  }) : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<RecurringTimer> {
  StreamSubscription<CountdownTimer> stream;
  Widget child;

  @override
  void initState() {
    child = widget.builder(calculateDifference());
    runTimer(calculateDifference());
    super.initState();
  }

  @override
  void dispose() {
    stream?.cancel();
    super.dispose();
  }

  Duration calculateDifference() {
    var now = DateTime.now();
    DateTime dateToReach = DateTime(
        now.year,
        now.month,
        now.day,
        widget.reachDate.hour,
        widget.reachDate.minute,
        widget.reachDate.second);

    if (now.isBefore(dateToReach)) {
      return dateToReach.difference(now);
    } else {
      return dateToReach.add(widget.recurrencePeriod).difference(now);
    }
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
      widget.onReached?.call();
      stream?.cancel();
      stream = null;
      runTimer(widget.recurrencePeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    return child ?? Container();
  }
}
