import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EasePayment extends StatefulWidget {
  final String hascodevalue;
  const EasePayment({
    Key? key,
    required this.hascodevalue,
  }) : super(key: key);

  @override
  State<EasePayment> createState() => _EasePaymentState();
}

class _EasePaymentState extends State<EasePayment> {
  static MethodChannel _channel = MethodChannel('easebuzz');
  String data = "";
  String key = 'WJE5UAJ51D';
  String txnId = 'vikas12345';
  String productinfo = 'part';
  String name = 'Ravi';

  // Add other parameters as needed

  String salt = 'Y3LVJ15S3M';
  String generateUniqueID() {
    DateTime now = DateTime.now();
    int randomComponent = Random().nextInt(1000);

    String uniqueID = '${now.millisecondsSinceEpoch}_$randomComponent';

    return uniqueID;
  }

  easeWay() async {
    const apiUrl = 'https://pay.easebuzz.in/payment/initiateLink';
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final Map<String, String> requestBody = {
      'key': key,
      'txnid': txnId,
      'amount': '1',
      'productinfo': 'Homofixcompany',
      'firstname': name,
      'phone': '9472064003',
      'email': 'kumarravu510@gmail.com',
      'hash': widget.hascodevalue,
      'surl': 'https://homofixcompany.com/account',
      'furl': 'https://homofixcompany.com/account',
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      // An error occurred
      print('Error: $e');
    }
  }

  // Future<void> startPayment(key) async {
  //   try {
  //     String accessKey =
  //         "d5e0fc2376d2d486baa753e93ca24558f664e18224e1f30acba820cc3c3df63d";
  //     String payMode = "test";

  //     Map<String, dynamic> parameters = {
  //       "access_key": accessKey,
  //       "pay_mode": payMode,
  //     };

  //     final paymentResponse =
  //         await _channel.invokeMethod("payWithEasebuzz", parameters);

  //     handlePaymentResponse(paymentResponse);
  //   } catch (e) {
  //     print("Error during payment: $e");
  //   }
  // }

  // Future<void> makePayment() async {
  //   String access_key =
  //       "d585288f016cd883005ef593bcda74e22ab813834cffbd6c3bb2feb54cf21dff";
  //   String pay_mode = "production";

  //   // Add txnId to the parameters
  //   Map<String, dynamic> parameters = {
  //     "access_key": access_key,
  //     "pay_mode": pay_mode,
  //   };

  //   try {
  //     final paymentResponse =
  //         await _channel.invokeMethod("payWithEasebuzz", parameters);

  //     // Parse paymentResponse as needed
  //     // ...
  //   } catch (e) {
  //     // Handle any exceptions
  //     print("Payment error: $e");
  //   }
  // }

  void handlePaymentResponse(Map<dynamic, dynamic> response) {
    String result = response['result'];

    if (result == 'success') {
      print("Payment successful");
    } else if (result == 'failure') {
      print("Payment failed");
    } else if (result == 'cancelled') {
      print("Payment cancelled");
    } else {
      print("Unknown result");
    }
  }

  void showSuccessMessage() {}

  void showFailureMessage() {}

  void showCancelledMessage() {}

  void showUnknownResultMessage() {}
  @override
  initState() {
    print(widget.hascodevalue);
    setState(() {
      data = widget.hascodevalue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: ElevatedButton(
              onPressed: () async {
                // String access_key =
                //     "d585288f016cd883005ef593bcda74e22ab813834cffbd6c3bb2feb54cf21dff";
                String pay_mode = "production";
                Object parameters = {
                  "access_key": widget.hascodevalue,
                  "pay_mode": pay_mode
                };
                final payment_response =
                    await _channel.invokeMethod("payWithEasebuzz", parameters);
                /* payment_response is the HashMap containing the response of the payment.
You can parse it accordingly to handle response */
              },
              child: Text(
                data,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
