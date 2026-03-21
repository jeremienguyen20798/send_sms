// import 'dart:math';

// import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_sms/featres/home/bloc/home_bloc.dart';
import 'package:send_sms/featres/home/bloc/home_event.dart';
import 'package:send_sms/featres/home/view/home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()
        ..add(HomeInitialEvent())
        ..add(CallStateListenEvent()),
      child: HomeView(),
    );
  }
}
