import 'package:flutter/material.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      height: 512,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Text(
              "AI",
              style: TextStyle(
                color: Colors.black,
                fontSize: 412,
                fontFamily: "Freesentation",
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
          Positioned(
            top: 450,
            left: 65,
            child: Text(
              "Short from video",
              style: TextStyle(
                color: Colors.black,
                fontSize: 48,
                fontFamily: "Freesentation",
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.visible,
            ),
          )
        ],
      ),
    );
  }
}
