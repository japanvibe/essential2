part of 'timer_bloc.dart';

@immutable
sealed class TimerState {}

final class TimerInitial extends TimerState {}

final class TimerCheckState extends TimerState {
  final DateTime date;
  TimerCheckState(this.date);
}

final class TimeCountdownState extends TimerState {
  final Duration countdownTime;
  TimeCountdownState(this.countdownTime);
}

final class DropTimerState extends TimerState {}

final class EndChallenge extends TimerState {}
