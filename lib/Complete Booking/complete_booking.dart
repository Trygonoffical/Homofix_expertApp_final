import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:homofix_expert/Complete%20Booking/complete_booking_details.dart';
import 'package:homofix_expert/Complete%20Booking/reboong_complete_details.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteBookingView extends StatefulWidget {
  // final List<Map<String, dynamic>> items;
  final String expertId;
  CompleteBookingView({Key? key, required this.expertId}) : super(key: key);

  @override
  State<CompleteBookingView> createState() => _CompleteBookingViewState();
}

class _CompleteBookingViewState extends State<CompleteBookingView>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> items = [];

  List<Map<String, dynamic>> itemsList = [];
  bool isLoading = true;
  late TabController _tabController;
  String _userId = '';
  String _username = '';

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id') ?? '';
    final username = prefs.getString('username') ?? '';
    setState(() {
      _userId = userId;
      _username = username;
      print("check :${_userId}");
    });
  }

  Color _getRandomColor() {
    Random random = new Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://support.homofixcompany.com/api/Task/?technician_id=${widget.expertId}'));
    if (response.statusCode == 200) {
      final parsedResponse = json.decode(response.body);
      final List<Map<String, dynamic>> itemsList =
          List<Map<String, dynamic>>.from(parsedResponse);
      setState(() {
        // items = itemsList.map<Map<String, dynamic>>((item) {
        //   Map<String, dynamic> booking = item['booking'];
        //   Map<String, dynamic> customer = item['customer'];
        //   return {
        //     'booking': booking,
        //     'customer': customer,
        //   };
        // }).toList();
        items = itemsList
            .map<Map<String, dynamic>>((item) => item['booking'])
            .where((booking) => booking['status'] == 'Completed')
            .toList();

        // sort items by order id
        items.sort((a, b) => a['order_id'].compareTo(b['order_id']));
        items.sort((a, b) =>
            a['booking']?['order_id']
                ?.compareTo(b['booking']?['order_id'] ?? 0) ??
            0);
        isLoading = false;
      });
      // print(parsedResponse);

      // print(widget.expertId);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> beabookingFetch() async {
    final response = await http.get(Uri.parse(
        'https://support.homofixcompany.com/api/Rebooking/?technician_id=${widget.expertId}'));

    if (response.statusCode == 200) {
      final parsedResponse = json.decode(response.body);
      itemsList = List<Map<String, dynamic>>.from(parsedResponse);

      // Filter items based on status
      itemsList =
          itemsList.where((item) => item['status'] == 'Completed').toList();

      isLoading = false;
      setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getUserId();
    fetchData();
    beabookingFetch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Assign':
        return Color(0xFFF7E2C2);
      case 'Inprocess':
        return Color(0xFFCEE986);
      case 'Proceed':
        return Color.fromARGB(255, 192, 129, 35);
      case 'Completed':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  int _selectedIndex = -1;
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff002790),
          elevation: 4,
          title: Text("Complete Booking".toUpperCase(),
              style: TextStyle(
                color: Colors.white,
              )),
          bottom: TabBar(
            labelColor: Colors.white,
            controller: _tabController,
            tabs: [
              Tab(
                text: 'Book Complete'.toUpperCase(),
              ),
              Tab(text: 'Reabook Complete'.toUpperCase()),
            ],
          ),
        ),
        // appBar: AppBar(
        //   title: Text("Complete Booking"),
        // ),
        body: TabBarView(
          controller: _tabController,
          children: [
            isLoading
                ? Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.black,
                    ),
                  )
                : items.isEmpty
                    ? Center(
                        child: Text(
                        "No Data".toUpperCase(),
                        style: TextStyle(color: Colors.grey),
                      ))
                    : SafeArea(
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox();
                          },
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            final booking = items[index];

                            final orderID = booking['order_id'];
                            final orderDate = DateFormat('dd/MM/yyyy').format(
                                DateTime.parse(booking['booking_date']));
                            final orderState = booking['id'];
                            final orderStatus = booking['status'];

                            // ------Booking Customer --------

                            final customerState = booking['customer']['state'];
                            final customerCity = booking['customer']['city'];
                            final customerZipcode =
                                booking['customer']['zipcode'];
                            final customerArea = booking['customer']['area'];
                            if (orderStatus != 'Completed') {
                              return SizedBox();
                            }
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(

                                        //  border: Border.all(width: 1, color: Colors.grey),
                                        ),
                                    child: Card(
                                      child: ListTile(
                                        onTap: () {
                                          Map<String, dynamic> customer =
                                              items[index]['customer'];
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CompleteBookingDetails(
                                                      expertId: _userId,
                                                      orderId: orderState,
                                                      city: customerCity,
                                                      area: customerArea,
                                                      zipCode: customerZipcode,
                                                      state: customerState,
                                                      productSet: booking[
                                                          'booking_product'],
                                                      products:
                                                          booking['products'],
                                                      customerdetails: customer,

                                                      //  bookingProducts: bookingProducts,
                                                      expertname: _username),
                                            ),
                                          );
                                        },
                                        leading: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              // border:
                                              //     Border.all(width: 1, color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white54
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1.5,
                                                  blurRadius: 10,
                                                  offset: Offset(
                                                    1,
                                                    1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            child: Image(
                                                image: AssetImage(
                                                    "assets/logoo.jpg")),
                                          ),
                                        ),
                                        title: Text(
                                          '$customerState',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff1b213c),
                                          ),
                                        ),
                                        subtitle: Text(
                                          "ID $orderID".toUpperCase(),
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
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Icon(
                                                    Icons.fiber_manual_record,
                                                    size: 12,
                                                    color: _getStatusColor(
                                                        orderStatus),
                                                  ),
                                                ),
                                                Text(
                                                  '$orderStatus',
                                                  style: TextStyle(
                                                    color: _getStatusColor(
                                                        orderStatus),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
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
            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : itemsList.isEmpty
                    ? Center(
                        child: Text('No new booking'.toUpperCase()),
                      )
                    : ListView.separated(
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox();
                        },
                        itemCount: itemsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final booking = itemsList[index];

                          // ------Booking Order --------

                          final orderID = booking['booking_product']['booking']
                                  ?['order_id'] ??
                              '';
                          final orderDate = DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(booking['date']));
                          final orderState = booking['id'];
                          final orderStatus = booking['status'];

                          // ------Booking Customer --------

                          final customerState = booking['booking_product']
                              ['booking']['customer']['state'];
                          final customerCity = booking['booking_product']
                              ['booking']['customer']['city'];
                          final customerZipcode = booking['booking_product']
                              ['booking']['customer']['zipcode'];
                          final customerArea = booking['booking_product']
                              ['booking']['customer']['area'];
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
                                                CompleteRebookingDetailScreen(
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
                                                    products: booking[
                                                            'booking_product']
                                                        ['booking']['products'],
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
                                            borderRadius:
                                                BorderRadius.circular(9),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white54
                                                    .withOpacity(0.5),
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
                                                '$customerState'
                                                    .substring(0, 1),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              backgroundColor:
                                                  _getRandomColor()),
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
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.fiber_manual_record,
                                                  size: 12,
                                                  color: _getStatusColor(
                                                      orderStatus),
                                                ),
                                              ),
                                              Text(
                                                '$orderStatus',
                                                style: TextStyle(
                                                  color: _getStatusColor(
                                                      orderStatus),
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
          ],
        ));
  }
}
