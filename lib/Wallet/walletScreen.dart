import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/Wallet/moneyAddwalet.dart';
import 'package:homofix_expert/Wallet/rezorPay.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'ease.dart';

class WalletScreen extends StatefulWidget {
  final String expertId;
  final String randomtxnId;
  WalletScreen({Key? key, required this.expertId, required this.randomtxnId})
      : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String key = 'WJE5UAJ51D';
  String txnId = '';
  String amount = '100.00';
  String productinfo = 'homofix';
  String name = 'Ravi';
  String salt = 'Y3LVJ15S3M';
  String globalHashValue = '';

  bool isLoading = true;
  late Timer timer;
  // List<dynamic> _technicianDataList = [];
  Map<String, dynamic> technicianDataMap = {};
  List<dynamic> _technicianDataList = []; // Declare _technicianDataList here
List<dynamic> _technicianSet = [];
  double _totalShare = 0;
  final _totalShareController = StreamController<double>();

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

  // String generateHash() {
  //   String inputString =
  //       '$key|${widget.randomtxnId}|1|Homofixcompany|$name|kumarravu510@gmail.com|||||||||||$salt';

  //   List<int> utf8Bytes = utf8.encode(inputString);

  //   Digest sha512Digest = sha512.convert(utf8Bytes);

  //   String sha512Hash = sha512Digest.toString();
  //   globalHashValue = sha512Hash;
  //   return sha512Hash;
  // }

  Future<void> _getTotalShare() async {
    final response = await http.get(Uri.parse(
        'https://support.homofixcompany.com/api/Wallet/GET/?technician_id=${widget.expertId}'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'];
      double totalShare = 0;
      for (var item in data) {
        if (item.containsKey('total_share')) {
          totalShare = double.parse(item['total_share'].toString());
          break;
        }
      }

      setState(() {
        _totalShare = totalShare;
        isLoading = false;
      });

      _totalShareController.add(totalShare);
    } else {
      throw Exception('Failed to get total share');
    }
  }

  Future<void> _fetchTechnicianSettlment() async {
    final url ="https://support.homofixcompany.com/api/Settlement-Details/?technician_id=${widget.expertId}";
       
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      setState(() {
        _technicianSet = parsed;
                isLoading = false;

        //   print(_technicianDataList);
      });

      // setState(() {
      //   isLoading = false;
      // });
    } else {
      // Handle error
    }
    setState(() {
      isLoading = false;
    });
  }
  Future<void> _fetchTechnicianDataList() async {
    final url =
        'https://support.homofixcompany.com/api/Wallet/History/GET/?technician_id=${widget.expertId}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);

      if (parsed['status'] == true) {
        // Extract the list of wallet history items from the 'data' key
        List<dynamic> walletHistoryList = parsed['data'];

        setState(() {
          // Assign the list to your _technicianDataList variable
          _technicianDataList = walletHistoryList;
        });
      } else {
        // Handle the case when status is not true
        print('Error: ${parsed['message']}');
      }
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    // timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   _getTotalShare();
    //   _fetchTechnicianDataList();
    // });
    _getTotalShare();
    _fetchTechnicianDataList();
    _fetchTechnicianSettlment();
    // generateHash();
    txnId = generateRandomTxnId();
    print("Generated TxnId: $txnId");
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
            title: Text("My Wallet".toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                )
                )),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.black,
              ))
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(globalHashValue),
                      Container(
                        height: 200,
                        width: double.infinity,
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [0, 0.25, 0.75, 1],
                            colors: [
                              Color(0x994E3DE9),
                              Color(0xff6956F0),
                              Color(0xff6956F0),
                              Color(0x994E3DE9),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  // colors: [Color(0xff6956F0), Color(0xff6956F0)],
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFFFFFFF)
                                  ]),
                            ),
                            child: Stack(
                              children: [
                                circleTopRight(),
                                circleBottomLeft(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Balance",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'en_IN',
                                            symbol: '₹',
                                            decimalDigits: 2,
                                          ).format(_totalShare),
                                          style: TextStyle(
                                              color: Color(0xff002790),
                                              //  color: Colors.black,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: (() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddMoneyWallet(
                                            expertId: widget.expertId,
                                            totalShare: _totalShare,
                                          )));
                            }),
                            child: Card(
                              elevation: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2.0, color: Color(0xff002790)),
                                ),
                                width: 150,
                                height: 50,
                                child: Center(
                                  child: Text(
                                    "Withdraw Request",
                                    style: TextStyle(
                                      color: Color(0xff002790),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          // EasePayment(
                                          //     hascodevalue: globalHashValue)
                                          MyRezorPey(
                                            expertId: widget.expertId,
                                            randomtxnId: txnId,
                                          )));
                            },
                            child: Card(
                              elevation: 2,
                              child: Container(
                                //   margin: EdgeInsets.all(8),
                                height: 50,
                                width: 150,
                                color: Color(0xff002790),
                                child: Center(
                                    child: Text(
                                  "Recharge",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
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
                              "WALLET HISTORY ".toUpperCase(),
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
                        child: SingleChildScrollView(
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            reverse: true,

                            itemCount: _technicianDataList.length ,
                            // +_technicianSet.length,
                            itemBuilder: (context, index) {
                              final technicianData =
                                  _technicianDataList[index];
                              bool isSettlementDeduction =
                                  technicianData['type'] == 'deduction';
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Card(
                                  elevation: 0,
                                  child: ListTile(
                                    title: Text(
                                      // '${_technicianDataList['settlement']??''}'.toString(),
                                      '${technicianData['type'] == 'deduction' ? 'deduction' : 'Added'}'
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(
                                          color: isSettlementDeduction
                                              ? Colors.red
                                              : Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${technicianData['description'] ?? ''}'
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xff002790),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.end,
                                      direction: Axis.vertical,
                                      children: [
                                        Text(
                                          '\u20B9 ${technicianData['amount'] ?? ''}'
                                              .toString(),
                                          style: TextStyle(
                                              color: isSettlementDeduction
                                                  ? Colors.red
                                                  : Colors.green,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '${technicianData['date'] ?? ''}'
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xff002790),
                                          ),
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
                    ],
                  ),
                ),
              ));
  }
}

Widget backgroundChart() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Balance",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // Text(
          //   NumberFormat.currency(
          //     locale: 'en_IN',
          //     symbol: '₹',
          //     decimalDigits: 2,
          //   ).format(_totalShare),
          //   style: TextStyle(
          //       color: Color(0xff6956F0),
          //       //  color: Colors.black,
          //       fontSize: 24,
          //       fontWeight: FontWeight.bold),
          // ),
          SizedBox(
            height: 3,
          ),
        ],
      ),
    ),
  );
}

Widget circleTopRight() {
  return Positioned(
    left: -80,
    top: -165,
    child: Container(
      width: 265,
      height: 265,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(-0.8, -0.7),
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00ADA4F3),
            Color(0xff002790),
          ],
        ),
      ),
    ),
  );
}

Widget circleBottomLeft() {
  return Positioned(
    right: -100,
    bottom: -200,
    child: Container(
      width: 280,
      height: 280,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment(0.9, -0.2),
          colors: [
            Color(0xff002790),
            Color.fromARGB(255, 206, 201, 245),
          ],
        ),
      ),
    ),
  );
}

List serviceName = ['Transfer ', 'Add Money '].toList();
List<Icon> serviceIcon = [
  Icon(
    Icons.payment,
    color: Color(0xff6956F0),
  ),
  Icon(
    Icons.attach_money,
    color: Color(0xff6956F0),
  ),
];
