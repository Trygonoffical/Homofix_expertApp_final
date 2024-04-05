import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'package:homofix_expert/Wallet/walletScreen.dart';
import 'package:http/http.dart' as http;

class MyPaymentScreen extends StatefulWidget {
  final String amounts;
  final String randomtxnId;
  final String hashvaluecode;
  final String realname;
  final String expertid;
  const MyPaymentScreen(
      {Key? key,
      required this.amounts,
      required this.expertid,
      required this.randomtxnId,
      required this.realname,
      required this.hashvaluecode})
      : super(key: key);

  @override
  State<MyPaymentScreen> createState() => _MyPaymentScreenState();
}

class _MyPaymentScreenState extends State<MyPaymentScreen> {
  static MethodChannel _channel = MethodChannel('easebuzz');

  String key = 'WJE5UAJ51D';
  String productinfo = 'part';
  String name = 'HomeFix_user';
  String txnId = '';
  String getdata = '';
  String salt = 'Y3LVJ15S3M';
  String globalHashValue = '';
  String easeresID = '';
  String generateRandomTxnId() {
    // Define the prefix for the txnId
    String prefix = "homofix_";

    // Define the length of the random part of the txnId
    int randomLength = 8;

    // Generate a random string of alphanumeric characters
    String randomString = generateRandomString(randomLength);

    // Concatenate the prefix and the random string to form the complete txnId
    String txnId = prefix + randomString;

    return txnId;
  }

  String generateHash() {
    String inputString =
        '$key|${generateRandomTxnId()}|${widget.amounts}|Homofixcompany|$name|kumarravu510@gmail.com|||||||||||$salt';

    List<int> utf8Bytes = utf8.encode(inputString);

    Digest sha512Digest = sha512.convert(utf8Bytes);

    String sha512Hash = sha512Digest.toString();
    globalHashValue = sha512Hash;
    return sha512Hash;
  }

  easeWay() async {
    const apiUrl = 'https://pay.easebuzz.in/payment/initiateLink';
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final Map<String, String> requestBody = {
      'key': key,
      'txnid': generateRandomTxnId(),
      'amount': widget.amounts,
      'productinfo': 'Homofixcompany',
      'firstname': widget.realname,
      'phone': '9472064003',
      'email': 'kumarravu510@gmail.com',
      'hash': widget.hashvaluecode,
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
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String data = jsonResponse['data'];

        setState(() {
          getdata = data;
        });
        // Print the extracted values
        print('Response Data: $data');
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      // An error occurred
      print('Error: $e');
    }
  }

  Future<void> startPayment() async {
    String pay_mode = "production";
    var parameters = {"access_key": getdata, "pay_mode": pay_mode};
    final Map response =
        await _channel.invokeMethod("payWithEasebuzz", parameters);

    // Retrieve the result value
    String result = response['result'];
    String response_details = response['payment_response']['easepayid'];

    print("payment resp$response_details");
    print("result=$result");
    // Check the result and handle accordingly
    if (result == "payment_successfull") {
      String response_details = response['payment_response']['easepayid'];

      setState(() {
        var easeresID = response_details;

        handleSuccessfulPayment(easeresID);
      });
    } else if (result == "payment_failed") {
      handleFailedPayment();
    } else {
      // Handle other results
      handleOtherResults(result);
    }
  }

  void handleSuccessfulPayment(easeresID) async {
    print('Payment successful!');
    print('Detailed Response: $easeresID');
    const url = 'https://support.homofixcompany.com/api/RechargeHistory/Post/';
    final dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';

    try {
      final data = {
        'technician_id': widget.expertid,
        'payment_id': easeresID,
        'amount': widget.amounts,
        'status': 'success',
      };

      final response = await dio.post(url, data: data);

      if (response.statusCode == 200) {
        // Payment data successfully posted to the API
        debugPrint('Payment data successfully posted to the API');

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => WalletScreen(
                randomtxnId: "",
                expertId: widget.expertid,
              ),
            ),
            (route) => false);
      } else {
        debugPrint(
            'Error posting payment data to the API: ${response.statusCode}');
      }
    } catch (e) {
      // Exception while posting payment data to the API
      debugPrint('Exception while posting payment data to the API: $e');
    }
    // You can navigate to a success screen, update UI, etc.
  }

  void handleFailedPayment() {
    // Handle the failed payment here
    print('Payment failed!');
    // You can show an error message, navigate to a failure screen, etc.
  }

  void handleOtherResults(String result) {
    // Handle other results if needed
    print('Result: $result');
    // You might want to handle other cases here
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   final url = 'https://support.homofixcompany.com/api/RechargeHistory/Post/';
  //   final dio = Dio();
  //   dio.options.headers['Content-Type'] = 'application/json';
  //   final data = {
  //     'technician_id': widget.expertId,
  //     'payment_id': response.paymentId,
  //     'amount': _controller.text,
  //     "status": 'success',
  //   };
  //   print('--------------Hello--------');
  //   print(_paymentId);
  //   try {
  //     final response = await dio.post(url, data: data);
  //     if (response.statusCode == 200) {
  //       // Payment data successfully posted to the API
  //       debugPrint('Payment data successfully posted to the API');
  //     } else {
  //       debugPrint(
  //           'Error posting payment data to the API: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Exception while posting payment data to the API
  //     debugPrint('Exception while posting payment data to the API: $e');
  //   }
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   debugPrint('Error: ${response.code} - ${response.message}');
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   debugPrint('External Wallet: ${response.walletName}');
  // }

  @override
  void initState() {
    easeWay();
    print('hascode${widget.hashvaluecode}');
    print('hascode${widget.hashvaluecode}');
    print("tech id ${widget.expertid}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(9)),
                child: ListTile(
                  leading: Image(
                    image: AssetImage("assets/homofix logo 2.png"),
                  ),
                  title: Text("Recharge your Wallet"),
                  subtitle: Text(
                    "₹ ${widget.amounts}.00",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        startPayment();
                        // print(getdata);
                        // String pay_mode = "production";
                        // Object parameters = {
                        //   "access_key": getdata,
                        //   "pay_mode": pay_mode
                        // };
                        // final payment_response = await _channel.invokeMethod(
                        //     "payWithEasebuzz", parameters);
                      },
                      child: Text(
                        "Pay Now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}

String generateRandomString(int length) {
  const chars =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  Random random = Random();
  String result = "";

  for (int i = 0; i < length; i++) {
    result += chars[random.nextInt(chars.length)];
  }

  return result;
}
