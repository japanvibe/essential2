part of 'timer_bloc.dart';

@immutable
sealed class TimerEvent {}

class TimerCheckEvent extends TimerEvent {}

class CountdownEvent extends TimerEvent {
  final DateTime? lastDate;
  CountdownEvent(this.lastDate);
}

class StartTimerEvent extends TimerEvent {}

class DropTimerEvent extends TimerEvent {}
