import 'package:ai_short_form_video_web/layouts/test.dart';
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
            MiddleButton(
                text: "text",
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SecondPage()));
                })
          ],
        ),
      ),
    );
  }
}
