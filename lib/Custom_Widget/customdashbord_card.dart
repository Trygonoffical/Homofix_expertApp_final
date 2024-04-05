import 'package:flutter/material.dart';
import 'package:homofix_expert/Custom_Widget/custom_responsive_h_w.dart';

class CustomWidget extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback onTap;

  const CustomWidget({
    Key? key,
    required this.imagePath,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9), color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: getMediaQueryHeight(context: context, value: 15),
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xff5a6065),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
