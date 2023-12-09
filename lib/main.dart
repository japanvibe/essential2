// ignore_for_file: prefer_const_constructors

import 'package:essential2/bloc/timer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocProvider(
            create: ((context) => TimerBloc()), child: MainPage()));
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<TimerBloc>().add(TimerCheckEvent());
    DateTime? date;
    DateTime? initialDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

    return Scaffold(
        appBar: AppBar(title: Text('Essential')),
        body: BlocConsumer<TimerBloc, TimerState>(builder: ((context, state) {
          if (state is TimeCountdownState) {
            return Center(
              child: Text(
                '${state.countdownTime.inDays} дн. : ${state.countdownTime.inHours - state.countdownTime.inDays * 24} час. : ${state.countdownTime.inMinutes - state.countdownTime.inHours * 60} мин. : ${state.countdownTime.inSeconds - state.countdownTime.inMinutes * 60} сек.',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            );
          }
          return Center(child: const Text('Выберите период'));
        }), listener: ((context, state) {
          if (state is TimerCheck) {
            startTimer(context, state, state.date);
          }
        })),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<TimerBloc, TimerState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      IconButton(
                          color: state is TimeCountdownState
                              ? Colors.grey
                              : Colors.black,
                          onPressed: state is TimeCountdownState
                              ? null
                              : () async {
                                  date = await showDatePicker(
                                      context: context,
                                      firstDate: initialDate,
                                      initialDate: initialDate,
                                      lastDate:
                                          DateTime(DateTime.now().year + 10));
                                },
                          icon: const Icon(Icons.date_range)),
                      IconButton(
                        color: state is TimeCountdownState
                            ? Colors.grey
                            : Colors.black,
                        onPressed: state is TimeCountdownState
                            ? null
                            : () {
                                date ??= initialDate;
                                startTimer(context, state, date!);
                              },
                        icon: const Icon(Icons.play_arrow),
                      ),
                      BlocListener<TimerBloc, TimerState>(
                        listener: (context, state) {
                          if (state is EndChallenge) {
                            context.read<TimerBloc>().add(DropTimerEvent());
                            ScaffoldMessenger.of(context).showMaterialBanner(
                                MaterialBanner(
                                    content: const Text(
                                        'Вы достигли поставленной цели!'),
                                    actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentMaterialBanner();
                                      },
                                      child: const Text('Хорошо'))
                                ]));
                          }
                        },
                        child: IconButton(
                            onPressed: () {
                              date = initialDate;
                              context.read<TimerBloc>().add(DropTimerEvent());
                            },
                            icon: const Icon(Icons.refresh)),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ));
  }

  void startTimer(BuildContext context, TimerState state, DateTime date) async {
    context.read<TimerBloc>().add(StartTimerEvent());
    context.read<TimerBloc>().add(CountdownEvent(date));
    while (state is TimerInitial ||
        state is TimerCheck ||
        state is TimeCountdownState) {
      await Future.delayed(const Duration(seconds: 1), () {
        context.read<TimerBloc>().add(CountdownEvent(date));
      });
    }
  }
}
