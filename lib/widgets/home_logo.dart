import 'package:flutter/material.dart';

class HomeLogo extends StatelessWidget {
  const HomeLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 512,
      height: 512,
      child: Text(
        "AI",
        style: TextStyle(
          color: Colors.black,
          fontSize: 412,
        ),
      ),
    );
  }
}
