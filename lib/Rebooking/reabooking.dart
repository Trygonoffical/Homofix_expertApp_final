import 'dart:convert';
import 'dart:math';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/Rebooking/rebookingDetails.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RebookingListView extends StatefulWidget {
  final String expertId;
  final String expertname;

  RebookingListView(
      {Key? key, required this.expertId, required this.expertname})
      : super(key: key);

  @override
  State<RebookingListView> createState() => _RebookingListViewState();
}

class _RebookingListViewState extends State<RebookingListView>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  bool get wantKeepAlive => true;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> itemsList = [];
  TextEditingController textController = TextEditingController();
  // bool isLoading = true;
  String _userId = '';
  String _username = '';
  Color _getRandomColor() {
    Random random = new Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id') ?? '';
    final username = prefs.getString('username') ?? '';
    setState(() {
      _userId = userId;
      _username = username;
    });
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://support.homofixcompany.com/api/Rebooking/?technician_id=${widget.expertId}'));

    if (response.statusCode == 200) {
      final parsedResponse = json.decode(response.body);
      itemsList = List<Map<String, dynamic>>.from(parsedResponse);
      isLoading = false;
      setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserId();
    fetchData();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Assign':
        return Colors.red;
      case 'Completed':
        return Color.fromARGB(255, 102, 236, 106);

      default:
        return Colors.grey;
    }
  }

  int _selectedIndex = -1;
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredList = itemsList.where((booking) {
      String orderStatus = booking['status'];
      String bookdate = booking['booking_date'];
      return orderStatus == 'Assign';
    }).toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff002790),
        elevation: 4,
        title: Text("Rebooking List".toUpperCase(),
            style: TextStyle(
              color: Colors.white,
            )),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : filteredList.isEmpty
                ? Center(
                    child: Text('No new booking'.toUpperCase()),
                  )
                : ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox();
                    },
                    itemCount: filteredList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final booking = filteredList[index];

                      // ------Booking Order --------

                      final orderID = booking['booking_product']['booking']
                              ?['order_id'] ??
                          '';
                      final orderDate = DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(booking['date']));
                      final orderState = booking['id'];
                      final orderStatus = booking['status'];
                      final apiDateTime =
                          DateTime.parse(booking['booking_date']);
                      final localDateTime = apiDateTime.toLocal();

                      final amPmFormat = DateFormat('dd/MM/yyyy hh:mm:ss a');
                      final formattedTime = amPmFormat.format(localDateTime);
                      // final bookDate = booking['booking_date'];
                      // ------Booking Customer --------

                      final customerState = booking['booking_product']
                          ['booking']['customer']['state'];
                      final customerCity = booking['booking_product']['booking']
                          ['customer']['city'];
                      final customerZipcode = booking['booking_product']
                          ['booking']['customer']['zipcode'];
                      final customerArea = booking['booking_product']['booking']
                          ['customer']['area'];
                      // final isCompleted = orderStatus == 'completed';
                      // final tileEnabled = isCompleted ? true : false;
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(),
                              child: Card(
                                elevation: 0,
                                color: _selectedIndex == index
                                    ? Colors.yellow
                                    : null,
                                child: ListTile(
                                  // enabled: tileEnabled,
                                  onTap: () {
                                    Map<String, dynamic> customer =
                                        itemsList[index]['booking_product']
                                            ['booking']['customer'];

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NewRebookingDetailScreen(
                                                expertId: _userId,
                                                orderId: orderState,
                                                city: customerCity,
                                                area: customerArea,
                                                zipCode: customerZipcode,
                                                state: customerState,
                                                productSet:
                                                    booking['booking_product']
                                                            ['booking']
                                                        ['booking_product'],
                                                products:
                                                    booking['booking_product']
                                                        ['booking']['products'],
                                                customerdetails: customer,
                                                status: orderStatus,
                                                bookDate: formattedTime,
                                                //  bookingProducts: bookingProducts,
                                                expertname: _username),
                                      ),
                                    );
                                  },
                                  leading: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(9),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.white54.withOpacity(0.5),
                                            spreadRadius: 1.5,
                                            blurRadius: 10,
                                            offset: Offset(
                                              1,
                                              1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                          child: Text(
                                            '$customerState'.substring(0, 1),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor: _getRandomColor()),
                                    ),
                                  ),
                                  title: Text(
                                    '$customerState',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff002790)),
                                  ),
                                  subtitle: Text(
                                    '$orderID',
                                    style: customSmallTextStyle,
                                  ),
                                  trailing: Wrap(
                                    direction: Axis.vertical,
                                    children: [
                                      Text(
                                        "$orderDate",
                                        style: customSmallTextStyle,
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.fiber_manual_record,
                                              size: 12,
                                              color:
                                                  _getStatusColor(orderStatus),
                                            ),
                                          ),
                                          Text(
                                            '$orderStatus',
                                            style: TextStyle(
                                              color:
                                                  _getStatusColor(orderStatus),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
