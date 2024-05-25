import 'dart:async';
import 'package:flutter/material.dart';

late TimerController timerController;

class TimerController {
  late Timer _timer;
  final Duration duration;
  final VoidCallback callback;

  TimerController({
    required this.duration,
    required this.callback,
  });

  void startPeriodic() {
    _timer = Timer.periodic(duration, (timer) {
      callback();
    });
  }

  void dispose() {
    _timer.cancel();
  }
}
