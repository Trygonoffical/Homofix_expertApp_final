import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/PDF%20View/pdfView.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Custom_Widget/custom_responsive_h_w.dart';

class CompleteBookingDetails extends StatefulWidget {
  final String expertId;
  final String city;
  final String area;
  final int zipCode;
  final String state;
  final int orderId;
  final String expertname;
  final Map<String, dynamic> customerdetails;
  final List<dynamic> products;
  final List<dynamic> productSet;

  CompleteBookingDetails({
    Key? key,
    required this.productSet,
    required this.state,
    required this.area,
    required this.city,
    required this.zipCode,
    required this.expertId,
    required this.expertname,
    required this.orderId,
    required this.products,
    required this.customerdetails,
  }) : super(key: key);

  @override
  State<CompleteBookingDetails> createState() => _CompleteBookingDetailsState();
}

class _CompleteBookingDetailsState extends State<CompleteBookingDetails>
    with SingleTickerProviderStateMixin {
  List<dynamic> orders = [];
  bool isLoading = false;
  List<dynamic> dataList = [];
  Color _buttonColor = Color(0xFFF7E2C2); // Default color for button
  String _selectedStatus = 'Completed'; // Default value for status
  late TabController _tabController;

  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // Set isLoading to true before fetching the data
    });

    try {
      final response = await http
          .get(Uri.parse('https://support.homofixcompany.com/api/Addons-GET/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Filter the data based on booking_id
        final filteredData =
            data.where((item) => item['booking_id'] == widget.orderId).toList();

        setState(() {
          dataList = filteredData;
        });
      } else {
        print('Failed to fetch data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    } finally {
      setState(() {
        isLoading = false; // Set isLoading to false after fetching the data
      });
    }
  }

  String pdf_file_path = '';
  void downloadpdf() async {
    isLoading = true;
    var urlpdf = Uri.parse(
        'https://support.homofixcompany.com/api/Expert/Invoice/${widget.orderId}');
    var response = await http.get(urlpdf);

    if (response.statusCode == 200) {
      setState(() {});
      var data = jsonDecode(response.body);
      var status = data['status'];
      var message = data['message'];
      var downloadUrl = data['download_url'];

      setState(() {
        pdf_file_path = downloadUrl;
        isLoading = false;
      });

      print('rrrr--------$urlpdf');
      print('Status: $status');
      print('Message: $message');
      print('Download URL: $downloadUrl');
      // _launchURL(downloadUrl);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    downloadpdf();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_selectedStatus) {
      case 'Assign':
        _buttonColor = Color(0xFFF7E2C2);
        break;
      case 'Inprocess':
        _buttonColor = Color(0xFFCEE986);
        break;
      case 'Proceed':
      default:
        _buttonColor = Color(0xFFCFEED0);
    }
    double totalPrice = 0.0;

    for (var product in widget.products) {
      totalPrice += product['price'];
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Book Complete".toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          elevation: 4,
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
              Tab(text: 'Customer'.toUpperCase()),
            ],
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ), // Show a circular progress indicator while loading
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height:
                            getMediaQueryHeight(context: context, value: 10),
                      ),

                      // Text(widget.orderId.toString()),
                      // Expanded(
                      //   child:
                      // ),
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
                              "Product Address".toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff002790),
                              ),
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
                                        // SizedBox(height: 4),
                                        // Text(widget.city),
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
                                color: Color(0xff002790),
                              ),
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _selectedStatus,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                              "Product List".toUpperCase(),
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
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: widget.products.length + dataList.length,
                          itemBuilder: (context, index) {
                            if (index < widget.products.length) {
                              final product = widget.products[index];
                              List<dynamic> proSet = widget.productSet;
                              final productName = product['name'];
                              int qnt = proSet[index]['quantity'];
                              final productTitle = product['product_title'];
                              final productPrice =
                                  product['selling_price'] * qnt;
                              final productImage = product['product_pic'];
                              final productQnt = product['quantity'];

                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Card(
                                  elevation: 0,
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
                                                ).format(productPrice),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff002790),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                "QTY:$qnt",
                                                style: TextStyle(
                                                  color: Color(0xff002790),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                          leading: productImage != null
                                              ? Image(
                                                  image: NetworkImage(
                                                      '$productImage'),
                                                  height: 80,
                                                  width: 60,
                                                )
                                              : Image.asset(
                                                  'assets/undraw_two_factor_authentication_namy.png',
                                                  height: 80,
                                                  width: 60,
                                                ),
                                          title: Text(
                                            "$productName",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff002790),
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
                                                  color: Color(0xff002790),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              final item =
                                  dataList[index - widget.products.length];
                              final qntty = item['spare_parts_id']['price'] *
                                  item['quantity'];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 0,
                                  child: ListTile(
                                    leading: Image.asset(
                                      'assets/undraw_two_factor_authentication_namy.png',
                                      height: 80,
                                      width: 60,
                                    ),
                                    title: Text(
                                      item['spare_parts_id']['spare_part']
                                          .toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff002790),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    subtitle: Text(
                                      item['description'].toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff002790),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    trailing: Wrap(
                                      direction: Axis.vertical,
                                      children: [
                                        Text(
                                          '\u20B9 $qntty',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff002790),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          "QTY:${item['quantity'].toString()}",
                                          style: TextStyle(
                                            color: Color(0xff002790),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
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
                                  color: Color(0xff002790),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height:
                              getMediaQueryHeight(context: context, value: 10),
                        ),
                        ListTile(
                          title: Text("Customer id "),
                          subtitle: Text(
                            ' ${widget.customerdetails['id']}'.toUpperCase(),
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
                            ' ${widget.customerdetails['mobile']}'
                                .toUpperCase(),
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
                              ' ${widget.customerdetails['address']}',
                              style: customSmallTextStyle,
                              overflow: TextOverflow
                                  .ellipsis, // add this line to add ellipsis (...) if the text overflows
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
            onTap: () {
              _launchURL(pdf_file_path);
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => Pdf_download(
              //               orderId: widget.orderId,
              //             )));
            },
            child: Container(
              height: getMediaQueryHeight(context: context, value: 45),
              color: Color(0xff002790),
              child: Center(
                child: Text(
                  'Download invoice',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
