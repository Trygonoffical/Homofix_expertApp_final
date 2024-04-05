import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homofix_expert/Adons/adonsAdd.dart';
import 'package:homofix_expert/Custom_Widget/custom_responsive_h_w.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NewOrderList extends StatefulWidget {
  final String expertId;
  final String city;
  final String orderDate;
  final String area;
  final int zipCode;
  final String state;
  final String pyMod;
  final int orderId;
  final String expertname;
  final Map<String, dynamic> customerdetails;
  final List<dynamic> products;
  final List<dynamic> productSet;
  final String status;
  const NewOrderList({
    Key? key,
    required this.productSet,
    required this.orderDate,
    required this.area,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.status,
    required this.expertId,
    required this.expertname,
    required this.orderId,
    required this.products,
    required this.customerdetails, 
    required this.pyMod,
  }) : super(key: key);

  @override
  State<NewOrderList> createState() => _NewOrderListState();
}

class _NewOrderListState extends State<NewOrderList>
    with SingleTickerProviderStateMixin {
  List<dynamic> orders = [];
  bool isLoading = true;
  Color _buttonColor = Color(0xFFF7E2C2); // Default color for button
  String _selectedStatus = '--Select--';
  List<String> _statusList = ['--Select--', 'Reached', 'Proceed'];

  late TabController _tabController;

  List<Map<String, dynamic>> items = [];
  List<dynamic> bookingProducts = [];

  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // Set isLoading to true before making the API call
    });

    try {
      final response = await http.get(Uri.parse(
          'https://support.homofixcompany.com/api/Task/?technician_id=${widget.expertId}'));

      if (response.statusCode == 200) {
        final parsedResponse = json.decode(response.body);

        final List<Map<String, dynamic>> itemsList =
            List<Map<String, dynamic>>.from(parsedResponse);
        // print('testing here');
        bookingProducts = itemsList
            .where((item) => item['booking']['id'] == widget.orderId)
            .map((item) => {'status': item['booking']['status']})
            .where((bookingProduct) => bookingProduct['status'] != null)
            .toList();

        setState(() {}); // Trigger a rebuild to update the widget tree
      }
    } catch (error) {
      // Handle error if any
    } finally {
      setState(() {
        isLoading =
            false; // Set isLoading to false after the API call is completed
      });
    }
  }

  //   for (var item in filteredItemsList) {
  //     final taxAmount = item['tax_amount'];
  //     print('Tax Amount: $taxAmount');
  //   }
  // }
  Future<void> updateStatus(String _selectedStatus, int orderId) async {
    final url = 'https://support.homofixcompany.com/api/Task/';
    final dio = Dio();

    try {
      final response = await dio.put(
        url,
        data: {
          'booking_id': orderId,
          'status': _selectedStatus,
        },
      );
      if (response.statusCode == 200) {
        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "Error updating status. Please try again later.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print('Error updating status: $e');
      Fluttertoast.showToast(
          msg: "Error updating status. Please try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void initState() {
    super.initState();
    //print(widget.productSet);
    _tabController = TabController(length: 2, vsync: this);
    fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void getCurruntPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Permission not given");
      LocationPermission asked = await Geolocator.requestPermission();
    } else {
      Position? currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition.latitude,
          currentPosition.longitude,
        );
        Placemark placemark = placemarks.first;
        String locationAddress =
            '${placemark.name}, ${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';

        Map<String, dynamic> data = {
          "technician_id": widget.expertId.toString(),
          "booking_id": widget.orderId.toString(),
          "location": locationAddress.toString()
        };
        String jsonData = jsonEncode(data);
        print(jsonData);

        final response = await http.post(
          Uri.parse('https://support.homofixcompany.com/api/Location/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonData,
        );

        if (response.statusCode == 201) {
          print("Data added successfully");
        } else {
          print("Failed to add data");
        }
      } else {
        print("Failed to get current position");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String statusView = bookingProducts.isNotEmpty
        ? bookingProducts[0]['status'] ?? 'N/A'
        : 'N/A';

    List<dynamic> proSet = widget.productSet;

    switch (_selectedStatus) {
      case 'Assign':
        _buttonColor = Color(0xFFF7E2C2);
        break;
      case 'Reached':
        _buttonColor = Color(0xFFCFEED0);
        break;
      case 'Proceed':
      default:
        _buttonColor = Color(0xFFFAF1A3);
    }
    double totalPrice = 0.0;

    for (var product in widget.products) {
      totalPrice += product['selling_price'];
    }
    if (statusView == 'Reached') {
      _statusList = ['Proceed'];
      _selectedStatus = 'Proceed';
    } else if (statusView == 'Proceed') {
      _selectedStatus = 'Proceed';
    } else {
      _statusList = ['--Select--', 'Reached'];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Order".toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Color(0xff002790),
        bottom: TabBar(
          labelColor: Colors.white,
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Your Order'.toUpperCase(),
            ),
            Tab(text: 'Your Customer'.toUpperCase()),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            ))
          : TabBarView(
              controller: _tabController,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: getMediaQueryHeight(context: context, value: 10),
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
                            "customer address".toUpperCase(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff002790)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            // border:
                            //     Border.all(width: 0.5, color: Color(0xFFD6D4D4)),
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.state,
                                        style: customTextStyle,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        widget.area + ', ' + widget.city,
                                        style: customSmallTextStyle,
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        widget.orderDate,
                                        style: customSmallTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Zip Code".toUpperCase(),
                                      style: customSmallTextStyle,
                                    ),
                                    SizedBox(height: 4),
                                    Text(widget.zipCode.toString(),
                                        style: customSmallTextStyle),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: getMediaQueryHeight(
                                  context: context, value: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 2,
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
                            "Product Status".toUpperCase(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff002790)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        height:
                            getMediaQueryHeight(context: context, value: 40),
                        decoration: BoxDecoration(
                          color: _buttonColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        width: double.infinity,
                        child: Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: (statusView == 'Proceed')
                                  ? Text(
                                      widget.status,
                                      style: TextStyle(color: Colors.black),
                                    )
                                  : DropdownButton<String>(
                                      hint: Text("--Select--"),
                                      icon: Icon(
                                        FontAwesomeIcons.angleDown,
                                        color: Colors.black,
                                      ),
                                      iconSize: 18,
                                      iconEnabledColor: Colors.black,
                                      isDense: true,
                                      isExpanded: true,
                                      value: _selectedStatus,
                                      underline: Container(
                                        height: 0,
                                      ),
                                      items: _statusList.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: isLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                  color: Colors.black,
                                                ))
                                              : Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedStatus = newValue!;
                                        });
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F0FD),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Product List".toUpperCase(),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff002790)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.products.length,
                          itemBuilder: (context, index) {
                            final product = widget.products[index];
                            int qnt = proSet[index]['quantity'];
                            final productName = product['name'];
                            final productId = product['id'];
                            final productTitle = product['product_title'];
                            final productPrice = product['selling_price'] * qnt;

                            final productDiscription = product['description'];
                            final productImage = product['product_pic'];

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 0,
                                //  margin: EdgeInsets.zero,
                                child: Container(
                                    child: Column(
                                  children: [
                                    SizedBox(
                                      height: getMediaQueryHeight(
                                          context: context, value: 10),
                                    ),
                                    ListTile(
                                      trailing: Wrap(
                                        direction: Axis.vertical,
                                        children: [
                                          Text(
                                            NumberFormat.currency(
                                              locale: 'en_IN',
                                              symbol: '₹',
                                              decimalDigits: 0,
                                            ).format(
                                              productPrice,
                                            ),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff002790)),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "QTY: $qnt",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xff002790)),
                                          )
                                        ],
                                      ),
                                      leading: productImage != null
                                          ? Image(
                                              image:
                                                  NetworkImage('$productImage'),
                                              height: 80,
                                              width: 60,
                                            )
                                          : Image.asset(
                                              'assets/undraw_two_factor_authentication_namy.png', // replace with your default image path
                                              height: 80,
                                              width: 60,
                                            ),
                                      title: Text(
                                        "$productName",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff1b213c),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$productTitle",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xff1b213c),
                                            ),
                                          ),
                                          // Html(data: "$productDiscription"),

                                          // Text(
                                          //   "$productDiscription",
                                          //   maxLines: 3,
                                          //   overflow: TextOverflow.ellipsis,
                                          // ),
                                        ],
                                      ),
                                    )

                                    //Text("$productDiscription")
                                  ],
                                )),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: getMediaQueryHeight(
                                  context: context, value: 10),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height:
                            getMediaQueryHeight(context: context, value: 10),
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
                              "Customer Details".toUpperCase(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff002790)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            getMediaQueryHeight(context: context, value: 10),
                      ),
                      ListTile(
                        title: Text("Payment Mode"),
                        subtitle: Text(
                          ' ${widget.pyMod}'.toUpperCase(),
                          style: customSmallTextStyle,
                        ),
                      ),
                      ListTile(
                        title: Text("Customer Name "),
                        subtitle: Text(
                          ' ${widget.customerdetails['admin']['first_name']}'
                              .toUpperCase(),
                          style: customSmallTextStyle,
                        ),
                      ),
                      ListTile(
                        title: Text("Customer Mobile "),
                        subtitle: Text(
                          ' ${widget.customerdetails['mobile']}'.toUpperCase(),
                          style: customSmallTextStyle,
                        ),
                      ),
                      ListTile(
                        title: Text("Customer State "),
                        subtitle: Text(
                          ' ${widget.customerdetails['state']}'.toUpperCase(),
                          style: customSmallTextStyle,
                        ),
                      ),
                      ListTile(
                        title: Text("Customer Address "),
                        subtitle: Container(
                          width: 200.0, // set a fixed width of 200 pixels
                          child: Text(
                            '${widget.customerdetails['address']} ${widget.customerdetails['area']} ${widget.customerdetails['city']} ${widget.customerdetails['zipcode']}',
                            style: customSmallTextStyle,
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            getMediaQueryHeight(context: context, value: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          onTap: () async {
            if (_selectedStatus == '--Select--') {
              Fluttertoast.showToast(
                msg: 'Please select a status',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } else {
              if (_selectedStatus == 'Reached') {
                Fluttertoast.showToast(
                  msg: 'Successfully Submitted',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );

                await updateStatus(_selectedStatus, widget.orderId);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewOrderList(
                      orderDate: widget.orderDate,
                      status: widget.status,
                      expertId: widget.expertId,
                      expertname: widget.expertname,
                      area: widget.area,
                      city: widget.city,
                      customerdetails: widget.customerdetails,
                      orderId: widget.orderId,
                      productSet: widget.productSet,
                      products: widget.products,
                      state: widget.state,
                      pyMod: widget.pyMod,
                      zipCode: widget.zipCode,
                    ),
                  ),
                );

                getCurruntPosition();
              } else {
                await updateStatus(_selectedStatus, widget.orderId);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAdomsPartScreen(
                      products: widget.products,
                      orderId: widget.orderId,
                      bookingStatus: widget.status,
                      productSet: widget.productSet,
                      expertId: widget.expertId,
                    ),
                  ),
                );
              }
            }
          },
          child: Container(
            height: getMediaQueryHeight(context: context, value: 45),
            color: Color(0xff002790),
            child: Center(
              child: Text(
                _selectedStatus == 'Proceed' ? 'Change Proceed' : 'Submit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
