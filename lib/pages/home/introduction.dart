import 'package:ai_short_form_video_web/pages/test.dart';
import 'package:ai_short_form_video_web/styles/colors.dart';
import 'package:ai_short_form_video_web/styles/fonts.dart';
import 'package:ai_short_form_video_web/widgets/middle_button.dart';
import 'package:flutter/material.dart';

class HomeComponent extends StatelessWidget {
  final double width;
  final double height;

  const HomeComponent({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "생성형 AI를 사용하여 나만의 동영상을 제작하고\n모든 소셜 미디어 플랫폼에 공유해보세요.",
              style: AppFonts.h1,
              textAlign: TextAlign.center,
            ),
            const Padding(padding: EdgeInsets.only(top: 30, bottom: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MiddleButton(
                    text: "지금 체험하기",
                    textColor: AppColors.black1,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SecondPage()));
                    }),
                const Padding(padding: EdgeInsets.only(left: 10, right: 10)),
                MiddleButton(
                  text: "로그인",
                  textColor: AppColors.black1,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SecondPage()));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
