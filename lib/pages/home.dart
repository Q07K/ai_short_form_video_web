import 'package:ai_short_form_video_web/pages/home/introduction.dart';
import 'package:ai_short_form_video_web/styles/colors.dart';
import 'package:ai_short_form_video_web/widgets/home_logo.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 1224;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment(0.64, -0.53),
              ),
            ),
            child: Center(
              child: Container(
                alignment: Alignment.center,
                child: isWideScreen
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          HomeLogo(),
                          HomeComponent(width: 512, height: 512),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          HomeLogo(),
                          HomeComponent(width: 512, height: 240),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
