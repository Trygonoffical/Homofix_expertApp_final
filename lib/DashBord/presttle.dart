import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

class MyWidget extends StatefulWidget {
  final String expertId;
  const MyWidget({Key? key,required this.expertId}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {

   bool isLoading = true;
  // List<dynamic> _technicianDataList = [];
  Map<String, dynamic> technicianDataMap = {};
List<dynamic> _technicianSet = [];
  
  Future<void> _fetchTechnicianSettlment() async {
    final url ="https://support.homofixcompany.com/api/Settlement-Details/?technician_id=${widget.expertId}";
       
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final parsed = json.decode(response.body);
      setState(() {
        _technicianSet = parsed;
                isLoading = false;

          print(_technicianSet);
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
  @override
  void initState() {
    // TODO: implement initState
    _fetchTechnicianSettlment();
    super.initState();
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
            title: Text('All Settlements'.toUpperCase(),
                style: TextStyle(
                color: Colors.white,
                )),
      ),
      body:SingleChildScrollView(
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              reverse: true,

              itemCount: _technicianSet.length ,
              // +_technicianSet.length,
              itemBuilder: (context, index) {
                final technicianData =
                    _technicianSet[index];
                bool isSettlementDeduction =
                      technicianData['settlement'] == 'Settlement Deduction';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Card(
                    elevation: 0,
                    child: ListTile(
                      title: Text(
                        // '${_technicianDataList['settlement']??''}'.toString(),
                        '${technicianData['settlement'] == 'Settlement Deduction' ? 'Amount Deduction' : 'Amount Added' }'
                            .toString(),
                            // .toUpperCase(),
                        style: TextStyle(
                            color:  isSettlementDeduction
                                    ? Colors.red
                                    : Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
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
                                color:  isSettlementDeduction
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
                ),
                );
              },
            ),
          ),
      );
  }
}