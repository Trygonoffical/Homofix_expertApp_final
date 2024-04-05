import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:homofix_expert/Custom_Widget/custom_medium_button.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/Wallet/moneyAddwalet.dart';

class AccountDetails {
  String? accountNo;
  String? ifscCode;
  String? accountHolderName;

  AccountDetails({this.accountNo, this.ifscCode, this.accountHolderName});
}

class TransferMoneyScreen extends StatefulWidget {
  final String expertId;
  final double totalShare;
  const TransferMoneyScreen(
      {Key? key, required this.expertId, required this.totalShare})
      : super(key: key);

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController accountNoController = TextEditingController();
  TextEditingController ifscCodeController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController bankController = TextEditingController();
  // List<dynamic> _dataList = [];

  Future<void> postData() async {
    Dio dio = Dio();
    String url = "https://support.homofixcompany.com/api/Kyc/";

    try {
      FormData formData = FormData.fromMap({
        "Ac_no": accountNoController.text,
        "bank_name": bankController.text,
        "ifsc_code": ifscCodeController.text,
        "bank_holder_name": accountHolderNameController.text,
        "branch": branchController.text,
        "technician_id": widget.expertId.toString(),
      });
      Response response = await dio.post(url, data: formData);
      if (response.statusCode == 201) {
        // handle success
        print(response.data);
      } else {
        // handle error
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      // handle error
      print(e.toString());
    }
  }

  AccountDetails _accountDetails = AccountDetails();

  int? _selectedIndex;
  @override
  void dispose() {
    accountHolderNameController.dispose();
    accountNoController.dispose();
    ifscCodeController.dispose();
    branchController.dispose();
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
        title: Text(
          "Bank Details".toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Add Bank Account",
                    style: customTextStyle,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Account Number.',
                          textAlign: TextAlign.start,
                          style:
                              TextStyle(color: Color(4288914861), fontSize: 18),
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
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                fontSize:
                                    16.0), // Increase the font size as desired
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Account no';
                              }
                              return null;
                            },
                            controller: accountNoController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15),
                  Column(children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'IFSC Code',
                        textAlign: TextAlign.start,
                        style:
                            TextStyle(color: Color(4288914861), fontSize: 18),
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
                            style: TextStyle(fontSize: 16.0),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'IFSC code';
                              }
                              return null;
                            },
                            controller: ifscCodeController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                            )),
                      ),
                    )
                  ]),
                  SizedBox(height: 15),
                  Column(children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Branch Name",
                        textAlign: TextAlign.start,
                        style:
                            TextStyle(color: Color(4288914861), fontSize: 18),
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
                            style: TextStyle(fontSize: 16.0),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Account Branch';
                              }
                              return null;
                            },
                            controller: branchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                            )),
                      ),
                    ),
                  ]),
                  SizedBox(height: 15),
                  Column(children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Account Holder's Name",
                        textAlign: TextAlign.start,
                        style:
                            TextStyle(color: Color(4288914861), fontSize: 18),
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
                            style: TextStyle(fontSize: 16.0),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter AccountHolder name';
                              }
                              return null;
                            },
                            controller: accountHolderNameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                            )),
                      ),
                    ),
                  ]),
                  SizedBox(height: 15),
                  Column(children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "Bank Name",
                        textAlign: TextAlign.start,
                        style:
                            TextStyle(color: Color(4288914861), fontSize: 18),
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
                            style: TextStyle(fontSize: 16.0),
                            controller: bankController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                            )),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 25,
                  ),
                  CustomContainerMediamButton(
                      buttonText: 'Proceed',
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          await postData();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddMoneyWallet(
                                expertId: widget.expertId,
                                totalShare: widget.totalShare,
                              ),
                            ),
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
