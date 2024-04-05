import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homofix_expert/Custom_Widget/custom_medium_button.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/Wallet/payment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyRezorPey extends StatefulWidget {
  final String expertId;
  final String randomtxnId;

  const MyRezorPey(
      {Key? key, required this.expertId, required this.randomtxnId})
      : super(key: key);

  @override
  _MyRezorPeyState createState() => _MyRezorPeyState();
}

class _MyRezorPeyState extends State<MyRezorPey> {
  TextEditingController _controller = TextEditingController();
  static MethodChannel _channel = MethodChannel('easebuzz');
  final _formKey = GlobalKey<FormState>();
  String real_time_amount = "";
  String key = 'WJE5UAJ51D';
  String name = 'Ravi';
  String salt = 'Y3LVJ15S3M';
  String globalHashValue = '';
  String txnId = '';
  String askKey = '';
  List<dynamic> _technicianDataList = [];
  late Timer timer;
  bool isLoading = true;
  String mainData = '';

  @override
  void initState() {
    super.initState();
    _fetchTechnicianDataList();
    // txnId = generateRandomTxnId();
    print("rezorPay TxnId: $txnId");
    _controller.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _fetchTechnicianDataList() async {
    final url =
        'https://support.homofixcompany.com/api/RechargeHistory/GET/?technician_id=${widget.expertId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      _technicianDataList = parsed['data'];
    } else {
      // Handle error
    }
    setState(() {
      isLoading = false;
    });
  }

  String generateRandomTxnId() {
    String prefix = "homofix_";
    int randomLength = 8;
    String randomString = generateRandomString(randomLength);
    return prefix + randomString;
  }

  String generateHash(String txnId) {
    String inputString =
        '$key|$txnId|$real_time_amount|Homofixcompany|$name|info@homofixcompany.com|||||||||||$salt';

    List<int> utf8Bytes = utf8.encode(inputString);

    Digest sha512Digest = sha512.convert(utf8Bytes);

    String sha512Hash = sha512Digest.toString();
    globalHashValue = sha512Hash;
    return sha512Hash;
  }

  Future<void> easeWay(String txnId) async {
    const apiUrl = 'https://pay.easebuzz.in/payment/initiateLink';

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final Map<String, String> requestBody = {
      'key': key,
      'txnid': txnId,
      'amount': real_time_amount,
      'productinfo': 'Homofixcompany',
      'firstname': name,
      'phone': '6202223861',
      'email': 'info@homofixcompany.com',
      'hash': generateHash(txnId),
      'surl': 'https://homofixcompany.com/account',
      'furl': 'https://homofixcompany.com/account',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      mainData = jsonResponse['data'];
      // setState(() {
      //   askKey = data;
      // });
      print("---------------------$askKey");
    } else {
      print('Error: ${response.statusCode}');
      print("---------------------$askKey");

      print('Response: ${response.body}');
    }
  }

  Future<void> startPayment() async {
    String pay_mode = "production";
    txnId = generateRandomTxnId();
    await easeWay(txnId);
    // if (askKey.isEmpty) {
    //   await easeWay(txnId);
    // }
    var parameters = {"access_key": mainData, "pay_mode": pay_mode};
    final Map response =
        await _channel.invokeMethod("payWithEasebuzz", parameters);

    String result = response['result'];
    String response_details = response['payment_response']['easepayid'];

    print("payment resp$response_details");
    print("result=$result");

    if (result == "payment_successfull") {
      String responseDetails = response['payment_response']['easepayid'];

      setState(() {
        var easeresID = responseDetails;
        handleSuccessfulPayment(easeresID);
      });
      Fluttertoast.showToast(
        msg: "Payment Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else if (result == "payment_failed") {
      Fluttertoast.showToast(
        msg: "Payment failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red, // You can customize the background color
        textColor: Colors.white, // You can customize the text color
      );
      // handleFailedPayment();
    } else if (result == "user_cancelled") {
      Fluttertoast.showToast(
        msg: "Payment failed ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red, // You can customize the background color
        textColor: Colors.white, // You can customize the text color
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff002790),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Recharge wallet".toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: InkWell(
        //       child: Icon(
        //         FontAwesomeIcons.qrcode,
        //         size: 35,
        //       ),
        //       onTap: () {
        //         showDialog(
        //           context: context,
        //           builder: (BuildContext context) {
        //             return Dialog(
        //               child: Container(
        //                 width: double.infinity,
        //                 height: double.infinity,
        //                 child: Image.asset('assets/qrScanner.jpg'),
        //               ),
        //             );
        //           },
        //         );
        //       },
        //     ),
        //   )
        // ],
      ),
      body: (isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Enter Amount',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Color(4288914861), fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Material(
                          borderRadius: BorderRadius.circular(10.0),
                          elevation: 0,
                          color: Colors.white,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: _controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                hintText: 'Amount',
                                hintStyle: TextStyle(
                                  color: Color(4288914861),
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 14.0),
                                prefixIcon: Icon(
                                  FontAwesomeIcons.indianRupee,
                                  color: Color(4288914861),
                                ),
                              ),
                              onChanged: (value) {
                                // Update the 'amount' variable with the current value
                                real_time_amount = value;
                                print(real_time_amount);
                                // Now you can use the 'amount' variable wherever you need it
                              },
                              validator: (value) {
                                // Validation logic to check if the input is not null or empty
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a  amount';
                                }
                                return null; // Return null if the input is valid
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    //  Text(
                    //   'Enter amount:',
                    //   style: customSmallTextStyle,
                    // ),
                    // TextField(
                    //   controller: _controller,
                    //   keyboardType:
                    //       TextInputType.numberWithOptions(decimal: true),
                    //   decoration: InputDecoration(
                    //     hintText: '\u20B9',
                    //   ),
                    // ),
                    SizedBox(height: 10.0),
                    CustomContainerMediamButton(
                        buttonText: 'Recharge Now',
                        onTap: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // generateHash();
                            startPayment();
                            _controller.clear();
                            print(globalHashValue);

                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => MyPaymentScreen(
                            //             hashvaluecode: globalHashValue,
                            //             amounts: _controller.text,
                            //             randomtxnId: widget.randomtxnId,
                            //             realname: name,
                            //             expertid: widget.expertId,
                            //           )),
                            // );
                          }

                          // amounts = _controller.text.trim();
                        }),
                    SizedBox(
                      height: 5,
                    ),
                    Card(
                      elevation: 0,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F0FD),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Recharge History ".toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff002790),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        //      height: MediaQuery.of(context).size.height - 200,
                        child: SingleChildScrollView(
                          child: ListView.builder(
                            reverse: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _technicianDataList.length,
                            itemBuilder: (context, index) {
                              final technicianData = _technicianDataList[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Card(
                                  elevation: 0,
                                  child: ListTile(
                                    title: Text(
                                      '${technicianData['payment_id'] ?? ''}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${technicianData['date'] ?? ''}',
                                      style: customSmallTextStyle,
                                    ),
                                    trailing: Wrap(
                                      direction: Axis.vertical,
                                      children: [
                                        Text(
                                          '\u20B9 ${technicianData['amount'] ?? ''}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          technicianData['status'] == 'success'
                                              ? 'successful'
                                              : '${technicianData['status'] ?? ''}',
                                          style: customSmallTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
    );
  }

  void handleSuccessfulPayment(easeresID) async {
    print('Payment successful!');
    print('Detailed Response: $easeresID');
    const url = 'https://support.homofixcompany.com/api/RechargeHistory/Post/';
    final dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';

    try {
      final data = {
        'technician_id': widget.expertId,
        'payment_id': easeresID,
        'amount': real_time_amount,
        'status': 'success',
      };

      final response = await dio.post(url, data: data);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Payment data successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor:
              Colors.green, // You can customize the background color
          textColor: Colors.white, // You can customize the text color
        );
        _fetchTechnicianDataList();
        // Payment dat
        //a successfully posted to the API
        debugPrint('Payment data successfully posted to the API');
      } else {
        debugPrint(
            'Error posting payment data to the API: ${response.statusCode}');
        Fluttertoast.showToast(
          msg: "Payment faild",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red, // You can customize the background color
          textColor: Colors.white, // You can customize the text color
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red, // You can customize the background color
        textColor: Colors.white, // You can customize the text color
      );
      // Exception while posting payment data to the API
      // debugPrint('Exception while posting payment data to the API: $e');
    }
    // You can navigate to a success screen, update UI, etc.
  }
}
