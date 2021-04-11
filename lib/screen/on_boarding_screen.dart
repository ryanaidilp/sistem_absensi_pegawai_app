import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:spo_balaesang/utils/view_util.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({this.page});

  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: onBoardingScreens,
        showSkipButton: true,
        skip: const Text("Skip"),
        next: const Icon(
          Icons.navigate_next,
          color: Colors.blueAccent,
          size: 32,
        ),
        onSkip: () {
          Get.off(() => page);
        },
        done: const Text("Selesai",
            style: TextStyle(fontWeight: FontWeight.w600)),
        onDone: () {
          Get.off(() => page);
        },
      ),
    );
  }
}
