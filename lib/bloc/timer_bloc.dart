import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  int? duration;

  TimerBloc() : super(TimerInitial()) {
    on<TimerCheckEvent>((event, emit) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('lastDate')) {
        int? millisecondsSinceEpoch = prefs.getInt('lastDate');
        DateTime date =
            DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch!);
        emit(TimerCheckState(date));
      }
    });

    on<CountdownEvent>((event, emit) async {
      if (state is! DropTimerState) {
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('lastDate')) {
          final now = DateTime.now();
          final lastDate = DateTime(event.lastDate!.year, event.lastDate!.month,
              event.lastDate!.day, now.hour, now.minute, now.second);
          await prefs.setInt('lastDate', lastDate.millisecondsSinceEpoch);
        }
        int? millisecondsSinceEpoch = prefs.getInt('lastDate');
        var countdownTime = DateTimeRange(
                start: DateTime.now(),
                end: DateTime.fromMillisecondsSinceEpoch(
                    millisecondsSinceEpoch!))
            .duration;
        if (!prefs.containsKey('duration')) {
          await prefs.setInt('duration', countdownTime.inHours);
        }
        duration ??= prefs.getInt('duration');
        if (countdownTime.inSeconds > 0) {
          emit(TimeCountdownState(countdownTime));
        } else {
          emit(EndChallenge());
        }
      }
    });

    on<StartTimerEvent>(
      (event, emit) {
        emit(TimerInitial());
      },
    );

    on<DropTimerEvent>(((event, emit) async {
      emit(DropTimerState());
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('lastDate')) {
        await prefs.remove('lastDate');
        await prefs.remove('duration');
      }
    }));
  }
}
