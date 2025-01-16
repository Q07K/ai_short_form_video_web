import 'package:ai_short_form_video_web/styles/fonts.dart';
import 'package:ai_short_form_video_web/pages/test.dart';
import 'package:ai_short_form_video_web/widgets/home_logo.dart';
import 'package:ai_short_form_video_web/widgets/middle_button.dart';
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
      body: Container(
        padding: const EdgeInsets.all(100),
        child: Row(
          children: <Widget>[
            const HomeLogo(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "생성형 AI를 사용하여 나만의 동영상을 제작하고\n모든 소셜 미디어 플랫폼에 공유해보세요.",
                  style: AppFonts.h1,
                  textAlign: TextAlign.center,
                ),
                const Padding(padding: EdgeInsets.only(top: 30, bottom: 30)),
                Row(
                  children: [
                    MiddleButton(
                        text: "test1",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SecondPage()));
                        }),
                    const Padding(
                        padding: EdgeInsets.only(left: 10, right: 10)),
                    MiddleButton(
                        text: "test2",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SecondPage()));
                        }),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
