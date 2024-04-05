import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homofix_expert/Custom_Widget/custom_medium_button.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/DashBord/dashbord.dart';
import 'package:homofix_expert/Wallet/select_Bank_option.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMoneyWallet extends StatefulWidget {
  final String expertId;

  final double totalShare;
  AddMoneyWallet({Key? key, required this.expertId, required this.totalShare})
      : super(key: key);

  @override
  State<AddMoneyWallet> createState() => _AddMoneyWalletState();
}

class _AddMoneyWalletState extends State<AddMoneyWallet> {
  bool isLoading = true;
  List<dynamic> _dataList = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  List<dynamic> _technicianDataList = [];
  late Timer timer;
  Future<void> _fetchTechnicianDataList() async {
    final url =
        'https://support.homofixcompany.com/api/Withdraw/Request/Get/?technician_id=${widget.expertId}';
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

  void _handlePaymentSuccess() async {
    const url = 'https://support.homofixcompany.com/api/Withdraw/Request/Post/';
    final dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    final data = {
      'amount': _amountController.text,
      'technician_id': widget.expertId,
    };
    print('--------------Hello--------');

    try {
      final response = await dio.post(url, data: data);
      if (response.statusCode == 200) {
        // Payment data successfully posted to the API
        debugPrint('Payment data successfully posted to the API');
        // ignore: use_build_context_synchronously
        Fluttertoast.showToast(
          msg: "Withdrawal request has been submitted",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashBord()),
          (route) => false,
        );
      } else {
        debugPrint(
            'Error posting payment data to the API: ${response.statusCode}');
      }
    } catch (e) {
      // Exception while posting payment data to the API
      debugPrint('Exception while posting payment data to the API: $e');
    }
  }

  Future<void> fetchData() async {
    final url = "https://support.homofixcompany.com/api/Kyc/";
    final dio = Dio();

    try {
      final response = await dio.get('$url?technician_id=${widget.expertId}');
      if (response.statusCode == 200) {
        setState(() {
          final responseData = response.data;
          print(responseData); // Print the fetched data to the console

          if (responseData is List) {
            _dataList = responseData
                .cast<dynamic>(); // Assign the converted List<dynamic> data
          } else {
            _dataList =
                []; // Assign an empty list if the response data is not of the expected type
          }

          _isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchTechnicianDataList();
    fetchData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectBankScreen(
                              amount: _amountController.text,
                              expertId: widget.expertId,
                              totalShare: widget.totalShare,
                            )),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(width: 1, color: Colors.white)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Add Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            ))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "Withdrawal Money from Wallet to Bank ",
                      //   style: customTextStyle,
                      // ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Total balance  ${widget.totalShare}",
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff002790),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
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
                              height: 5,
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
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  keyboardType: TextInputType.number,
                                  maxLength:
                                      widget.totalShare.toString().length,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Amount ₹';
                                    }
                                    if (double.parse(value) >
                                        widget.totalShare) {
                                      return 'Withdraw amount cannot be greater than total shared amount';
                                    }
                                    if (0 > double.parse(value)) {
                                      return 'Withdraw amount cannot be less than 0';
                                    }
                                    return null;
                                  },
                                  controller: _amountController,
                                  decoration: InputDecoration(
                                    counterText: '',
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      CustomContainerMediamButton(
                        buttonText: "Proceed",
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_dataList.isEmpty) {
                              // Show a message indicating that the user needs to add a bank account
                              Fluttertoast.showToast(
                                msg:
                                    "Request failed. Please add account details.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else {
                              // Proceed with the payment since the dataList is not empty
                              _handlePaymentSuccess();
                            }
                          }
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: _technicianDataList.length,
                          itemBuilder: (context, index) {
                            final technicianData = _technicianDataList[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Card(
                                elevation: 0,
                                child: ListTile(
                                  title: Text(
                                    '${technicianData['id'] ?? ''}'.toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${technicianData['date'] ?? ''}'
                                        .toString(),
                                    style: customSmallTextStyle,
                                  ),
                                  trailing: Wrap(
                                    direction: Axis.vertical,
                                    children: [
                                      Text(
                                        '\u20B9 ${technicianData['amount'] ?? ''}'
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        ' ${technicianData['status'] ?? ''}'
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
