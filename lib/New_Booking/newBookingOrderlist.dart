import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/New_Booking/bookingDetail.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

//
class ProductScreenView extends StatefulWidget {
  final String expertId;
  
  final String expertname;
  const ProductScreenView(
      {Key? key, required this.expertId, required this.expertname})
      : super(key: key);

  @override
  State<ProductScreenView> createState() => _ProductScreenViewState();
}

class _ProductScreenViewState extends State<ProductScreenView>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> items = [];
  @override
  bool get wantKeepAlive => true;
  TextEditingController textController = TextEditingController();
  bool isLoading = true;
  String _userId = '';
  String _username = '';
  Color _getRandomColor() {
    Random random = Random();
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

  List<Map<String, dynamic>> allItemsList = [];

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://support.homofixcompany.com/api/Task/?technician_id=${widget.expertId}'));
    if (response.statusCode == 200) {
      final parsedResponse = json.decode(response.body);
      final List<Map<String, dynamic>> itemsList =
          List<Map<String, dynamic>>.from(parsedResponse);
      print(response.body);
      final List<dynamic> bookingProducts = parsedResponse
          .map((item) => item['booking_product'])
          .where((bookingProduct) => bookingProduct != null)
          .toList();

      // final List<dynamic> productIds = bookingProducts
      //     .expand<dynamic>((bookingProduct) => bookingProduct)
      //     .map<dynamic>((product) => product['product_id'])
      //     .toList();/
      // cash_on_service online

      // final List<dynamic> productrealIds = bookingProducts
      //     .expand<dynamic>((bookingProduct) => bookingProduct)
      //     .map<dynamic>((product) => product['id'])
      //     .toList();

      setState(() {
        allItemsList = itemsList;
        items = itemsList
            .map<Map<String, dynamic>>((item) => item['booking'])
            .where((booking) => booking['status'] != 'Completed')
            .toList();

        // sort items by order id
        items.sort((a, b) => a['order_id'].compareTo(b['order_id']));
        items.sort((a, b) =>
            a['booking']?['order_id']
                ?.compareTo(b['booking']?['order_id'] ?? 0) ??
            0);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  String searchQuery = '';
  void searchByOrderId(String orderId) {
    setState(() {
      searchQuery = orderId;
      items = allItemsList
          .map<Map<String, dynamic>>((item) => item['booking'])
          .where((booking) =>
              booking['status'] != 'Completed' &&
              booking['order_id'].toString().contains(searchQuery))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserId();
    // timer = Timer.periodic(Duration(seconds: 1), (timer) {
    //   _fetchTechnicianDataList();
    // });
    fetchData();

    // fetchBookingDetails().then((bookingDetails) {
    //   setState(() {
    //     _bookingDetails = bookingDetails;
    //   });
    // });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Assign':
        return Color(0xFFF7E2C2);
      case 'Inprocess':
        return Color(0xFFCFEED0);
      case 'Proceed':
        return Color(0xFFFAF1A3);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int _selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Booking'.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xff002790),
      ),
      // appBar: PreferredSize(
      //     preferredSize: const Size(double.infinity, 65),
      //     child: SafeArea(
      //         child: Container(
      //       decoration:
      //           const BoxDecoration(color: Color(0xff002790), boxShadow: [
      //         BoxShadow(
      //             color: Colors.black26,
      //             blurRadius: 3,
      //             spreadRadius: 0,
      //             offset: Offset(0, 5))
      //       ]),
      //       alignment: Alignment.center,
      //       child: GestureDetector(
      //         onTap: () {
      //           // Prevent keyboard from closing
      //           FocusScope.of(context).requestFocus(FocusNode());
      //         },
      //         child: AnimationSearchBar(
      //           searchIconColor: Colors.white,
      //           backIcon: FontAwesomeIcons.arrowLeft,
      //           backIconColor: Colors.white,
      //           centerTitle: 'Your Booking'.toUpperCase(),
      //           centerTitleStyle: const TextStyle(
      //             fontWeight: FontWeight.w500,
      //             color: Colors.white,
      //             fontSize: 20,
      //           ),
      //           onChanged: (text) {
      //             // Update search query and filter items
      //             setState(() {
      //               items = allItemsList
      //                   .map<Map<String, dynamic>>((item) => item['booking'])
      //                   .where((booking) =>
      //                       booking['status'] != 'Completed' &&
      //                       booking['order_id']
      //                           .toString()
      //                           .contains(searchQuery))
      //                   .toList();
      //             });
      //           },
      //           cursorColor: Colors.black,
      //           searchTextEditingController: textController,
      //           searchFieldDecoration: BoxDecoration(
      //             color: Colors.white,
      //             border: Border.all(color: Colors.white, width: .5),
      //             borderRadius: BorderRadius.circular(15),
      //           ),
      //           horizontalPadding: 5,
      //           // closeSearchOnSuffixTap: false, // Add this line to prevent auto-closing
      //           // closeSearchOnSubmit: false, // Add this line to prevent auto-closing
      //         ),
      //       ),
      //     ))),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : items.isEmpty
                ? Center(
                    child: Text('No new booking'.toUpperCase()),
                  )
                : ListView.separated(
                 
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox();
                    },
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final booking = items[index];
                      // print(booking['cash_on_service']);
                      // print(booking['online']);
                      // payment mode status

                     
                      // print(pyMod);
                      // ------Booking Order --------

                      final orderID = booking['order_id'];
                      String pyMod = booking['cash_on_service'] ? 'Cash on Service' : 'Online' ;
                      final orderDate = DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(booking['booking_date']));
                      final apiDateTime =
                          DateTime.parse(booking['booking_date']);
                      final localDateTime = apiDateTime.toLocal();

                      final amPmFormat = DateFormat('dd/MM/yyyy hh:mm:ss a');
                      final formattedTime = amPmFormat.format(localDateTime);

                      // final dateTimeFormat =
                      //  DateFormat('hh:mm:ss')
                      //     .format(DateTime.parse(booking['booking_date']));
                      // final DateTime bookingDate =
                      //     DateTime.parse(booking['booking_date']);
                      // final String formattedDateTime =
                      //     dateTimeFormat.format(bookingDate);

                      final orderState = booking['id'];
                      final orderStatus = booking['status'];

                      // ------Booking Customer --------

                      final customerState = booking['customer']['state'];
                      final customerCity = booking['customer']['city'];
                      final customerZipcode = booking['customer']['zipcode'];
                      final customerArea = booking['customer']['area'];

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
                                  onTap: () {
                                    Map<String, dynamic> customer =
                                        items[index]['customer'];

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewOrderList(
                                            expertId: _userId,
                                            orderId: orderState,
                                            city: customerCity,
                                            area: customerArea,
                                            zipCode: customerZipcode,
                                            state: customerState,
                                            pyMod: pyMod,
                                            orderDate: formattedTime,
                                            // qnt: booking['booking_product'],
                                            productSet:
                                                booking['booking_product'],
                                            products: booking['products'],
                                            customerdetails: customer,
                                            status: orderStatus,
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
                                    '$customerState'.toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff002790),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$orderID',
                                    style: customSmallTextStyle,
                                  ),
                                  trailing: Wrap(
                                    direction: Axis.vertical,
                                    children: [
                                      Text(
                                        "$orderDate".toString(),
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
