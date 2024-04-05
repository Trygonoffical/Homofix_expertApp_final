import 'package:flutter/material.dart';

class MyCustomCard extends StatelessWidget {
  final Widget child;

  MyCustomCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      //  height: getMediaQueryHeight(context: context, value: 80),
      //  margin: EdgeInsets.all(16),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        //  color: Color(0xff7d68f1),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }
}
