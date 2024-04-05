import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:homofix_expert/Custom_Widget/custom_medium_button.dart';
import 'package:homofix_expert/Wallet/transfer_money.dart';
import 'package:http/http.dart' as http;

import '../Custom_Widget/custom_text_style.dart';

class SelectBankScreen extends StatefulWidget {
  final String amount;
  final String expertId;
  final double totalShare;

  const SelectBankScreen({
    Key? key,
    required this.amount,
    required this.expertId,
    required this.totalShare,
  }) : super(key: key);

  @override
  State<SelectBankScreen> createState() => _SelectBankScreenState();
}

class _SelectBankScreenState extends State<SelectBankScreen> {
  List<dynamic> _dataList = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

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
    super.initState();
    fetchData();
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
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Select Account",
                                style: customTextStyle,
                              )),
                          Expanded(
                            child: InkWell(
                              onTap: (() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TransferMoneyScreen(
                                              expertId: widget.expertId,
                                              totalShare: widget.totalShare,
                                            )));
                              }),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    width: 2.0,
                                    color: Color(0xff002790),
                                  ),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      "Add New",
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
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      ListTileTheme(
                        child: ListView.separated(
                          separatorBuilder: (context, index) => Container(
                            height: 0.5,
                            color: Color.fromARGB(255, 201, 200, 200),
                          ),
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _dataList.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isActive =
                                _dataList[index]['bank_active'] ?? false;

                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Selected Please Update'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                  if (_dataList[index]['bank_active'] ??
                                      false) {
                                    _selectedIndex = index;
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border: _selectedIndex == index
                                      ? Border.all(
                                          width: 0.5,
                                          color: Color(0xff002790),
                                        )
                                      : null,
                                ),
                                child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = index;
                                      });
                                    },
                                    leading: Icon(
                                      FontAwesomeIcons.bank,
                                      color: Color(0xff002790),
                                    ),
                                    title: Text(
                                      _dataList[index]['bank_holder_name']
                                          .toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff002790),
                                      ),
                                    ),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _dataList[index]['branch'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff002790),
                                          ),
                                        ),
                                        Text(
                                          _dataList[index]['Ac_no'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff002790),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: _selectedIndex == index
                                        ? Icon(
                                            FontAwesomeIcons.checkCircle,
                                            color: Colors.green,
                                          )
                                        : null),
                              ),
                            );
                            //   tileColor: isActive ? Color(0xff002790) : null,
                            //     title: Text(
                            //       _dataList[index]['bank_holder_name']
                            //           .toString(),
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //       //   color: isActive
                            //       //       ? Colors.white
                            //       //       : Color(0xff002790),
                            //       // ),
                            //     ),
                            //     subtitle: Text(
                            //       _dataList[index]['branch'],
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         color: isActive
                            //             ? Colors.white
                            //             : Color(0xff002790),
                            //       ),
                            //     ),
                            //     trailing: Column(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Text(
                            //           _dataList[index]['Ac_no'],
                            //           style: TextStyle(
                            //             fontWeight: FontWeight.bold,
                            //             color: isActive
                            //                 ? Colors.white
                            //                 : Color(0xff002790),
                            //           ),
                            //         ),
                            //         Text(
                            //           _dataList[index]['ifsc_code'],
                            //           style: TextStyle(
                            //             fontWeight: FontWeight.bold,
                            //             color: isActive
                            //                 ? Colors.white
                            //                 : const Color(0xff002790),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Visibility(
                          visible: _dataList.isNotEmpty,
                          child: CustomContainerMediamButton(
                            buttonText: "Update",
                            onTap: () async {
                              if (_dataList.isNotEmpty &&
                                  _selectedIndex != -1) {
                                final selectedBank = _dataList[_selectedIndex];

                                for (var i = 0; i < _dataList.length; i++) {
                                  if (i != _selectedIndex) {
                                    _dataList[i]['bank_active'] = false;
                                  }
                                }

                                if (!selectedBank['bank_active']) {
                                  final url = Uri.parse(
                                      'https://support.homofixcompany.com/api/Kyc/');
                                  final response = await http.put(url, body: {
                                    'id': selectedBank['id'].toString(),
                                    'technician_id': widget.expertId.toString(),
                                    'bank_active': 'True',
                                  });
                                  if (response.statusCode == 200) {
                                    setState(() {
                                      selectedBank['bank_active'] = true;
                                    });
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Bank activated!'),
                                      duration: Duration(seconds: 2),
                                    ));
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Failed to activate bank'),
                                      duration: Duration(seconds: 2),
                                    ));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text('Bank already activated!'),
                                    duration: Duration(seconds: 2),
                                  ));
                                }
                              } else if (_dataList.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'Please put the account select button above to select the bank account'),
                                  duration: Duration(seconds: 2),
                                ));
                              }
                            },
                          )),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
