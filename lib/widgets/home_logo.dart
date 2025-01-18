import 'package:flutter/material.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 512,
        height: 512,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: const Offset(15, 0),
              child: const Text(
                "AI",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 412,
                  fontFamily: "Freesentation",
                  fontWeight: FontWeight.w800,
                  height: 512 / 412,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
            const Positioned(
              top: 400,
              child: Text(
                "Short from video",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 48,
                  fontFamily: "Freesentation",
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
