// import 'dart:math';

// import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_sms/featres/home/bloc/home_bloc.dart';
import 'package:send_sms/featres/home/bloc/home_event.dart';
import 'package:send_sms/featres/home/view/home_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final floating = Floating();

  // @override
  // void didChangeDependencies() {
  //   // _autoEnablePip();
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()
        ..add(HomeInitialEvent())
        ..add(CallStateListenEvent()),
      child: HomeView(),
    );
  }

  // Future<void> enablePip(
  //   BuildContext context, {
  //   bool autoEnable = false,
  // }) async {
  //   final rational = Rational.landscape();
  //   final screenSize =
  //       MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
  //   final height = screenSize.width ~/ rational.aspectRatio;
  //   final arguments = autoEnable
  //       ? OnLeavePiP(
  //           aspectRatio: rational,
  //           sourceRectHint: Rectangle<int>(
  //             0,
  //             (screenSize.height ~/ 2) - (height ~/ 2),
  //             screenSize.width.toInt(),
  //             height,
  //           ),
  //         )
  //       : ImmediatePiP(
  //           aspectRatio: rational,
  //           sourceRectHint: Rectangle<int>(
  //             0,
  //             (screenSize.height ~/ 2) - (height ~/ 2),
  //             screenSize.width.toInt(),
  //             height,
  //           ),
  //         );
  //   final status = await floating.enable(arguments);
  //   debugPrint('PIP enable: ${status.toString()}');
  // }

  // void _autoEnablePip() {
  //   enablePip(context, autoEnable: true);
  // }
}
