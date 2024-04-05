import 'package:flutter/material.dart';
import 'package:homofix_expert/Custom_Widget/custom_responsive_h_w.dart';

class CustomContainerMediamButton extends StatefulWidget {
  final String buttonText;
  final Function onTap;

  CustomContainerMediamButton({required this.buttonText, required this.onTap});

  @override
  _CustomContainerMediamButtonState createState() =>
      _CustomContainerMediamButtonState();
}

class _CustomContainerMediamButtonState
    extends State<CustomContainerMediamButton> {
  bool _isLoading = false;
  void dispose() {
    _isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        await widget.onTap();
        setState(() {
          _isLoading = false;
        });
      },
      child: Container(
        width: double.infinity,
        height: getMediaQueryHeight(context: context, value: 45),
        decoration: BoxDecoration(
          color: Color(0xff002790),
          // gradient:
          //     LinearGradient(colors: [Color(0xffC7BFFA), Color(0xff6956F0)]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  widget.buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getMediaQueryHeight(context: context, value: 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class CustomContainerSmallButton extends StatelessWidget {
  final String buttonText;
  final Function onTap;

  CustomContainerSmallButton({required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap(),
      child: Container(
        width: getMediaQueryWidth(context: context, value: 180),
        height: getMediaQueryHeight(context: context, value: 45),
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(4283794685), Color(4283794685)]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                buttonText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getMediaQueryHeight(context: context, value: 21),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: getMediaQueryWidth(context: context, value: 15),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
