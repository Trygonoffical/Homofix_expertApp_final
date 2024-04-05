import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homofix_expert/Custom_Widget/custom_responsive_h_w.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/DashBord/dashbord.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class CompleteRebookingDetailScreen extends StatefulWidget {
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

  final String status;
  const CompleteRebookingDetailScreen({
    Key? key,
    required this.productSet,
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
  }) : super(key: key);

  @override
  State<CompleteRebookingDetailScreen> createState() =>
      _CompleteRebookingDetailScreenState();
}

class _CompleteRebookingDetailScreenState
    extends State<CompleteRebookingDetailScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> orders = [];

  Color _buttonColor = Color(0xFFF7E2C2); // Default color for button
  String _selectedStatus = '--Select--';
  List<String> _statusList = ['--Select--', 'reached', 'proceed'];
  late TabController _tabController;
  List<dynamic> dataList = [];
  bool isLoading = true;
  List<Map<String, dynamic>> items = [];

  double progress = 0;

  // Track if the PDF was downloaded here.
  bool didDownloadPDF = false;

  // Show the progress status to the user.
  String progressString = 'File has not been downloaded yet.';

  // API URL for downloading the PDF file.
  String pdfUrl = 'https://support.homofixcompany.com/api/invoice/download/3/';

  // File name for the downloaded PDF.
  String fileName = 'invoice.pdf';

  // This method uses Dio to download a file from the given URL
  // and saves the file to the provided `savePath`.
  Future<void> downloadFiles(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: updateProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );
      File file = File(savePath);
      await file.writeAsBytes(response.data, flush: true);
      setState(() {
        progress = 1;
        progressString =
            '✅ File has finished downloading. Try opening the file.';
        didDownloadPDF = true;
      });
    } catch (e) {
      print(e);
    }
  }

  // You can update the download progress here so that the user is
  // aware of the long-running task.
  void updateProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        progress = received / total;
        if (progress >= 1) {
          progressString =
              '✅ File has finished downloading. Try opening the file.';
          didDownloadPDF = true;
        } else {
          progressString =
              'Download progress: ${(progress * 100).toStringAsFixed(0)}% done.';
        }
      });
    }
  }

  // Future<void> _getUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getString('id') ?? '';
  //   final username = prefs.getString('username') ?? '';
  //   setState(() {
  //     _userId = userId;
  //     _username = username;
  //     print("check :${_userId}");
  //   });
  // }
  Future<void> downloadFile() async {
    final url = 'https://support.homofixcompany.com/api/invoice/download/3/';

    // Send the HTTP GET request
    final response = await http.get(Uri.parse(url));

    // Get the directory for storing the downloaded file
    final directory = await getApplicationDocumentsDirectory();

    // Create a file in the directory with a unique name
    final file = File('${directory.path}/invoice.pdf');

    // Write the file
    await file.writeAsBytes(response.bodyBytes);
    final filePath = file.path;
    print('File downloaded to: $filePath');
  }

  Future<void> updateStatus(String _selectedStatus, String expertId) async {
    final url =
        'https://support.homofixcompany.com/api/Rebooking/Status/Update';
    final dio = Dio();

    try {
      final response = await dio.patch(
        url,
        data: {
          'technician_id': expertId,
          'status': _selectedStatus,
        },
      );
      if (response.statusCode == 200) {
        setState(() {});
        Fluttertoast.showToast(
          msg: "Order Completed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        ).then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashBord()),
            (route) => false));
      } else {
        Fluttertoast.showToast(
          msg: "Error updating status. Please try again later.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
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
        fontSize: 16.0,
      );
    }
  }

  // Future<void> updateStatus(
  //   String _selectedStatus,
  // ) async {
  //   final url =
  //       'https://support.homofixcompany.com/api/Rebooking/Status/Update';
  //   final dio = Dio();

  //   try {
  //     final response = await dio.patch(
  //       url,
  //       data: {
  //         'technician_id': widget.expertId,
  //         'status': _selectedStatus,
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       setState(() {

  //       });
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: "Error updating status. Please try again later.",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0,
  //       );
  //     }
  //   } catch (e) {
  //     print('Error updating status: $e');
  //     Fluttertoast.showToast(
  //       msg: "Error updating status. Please try again later.",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //   }
  // }
  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // Set isLoading to true before fetching the data
    });

    try {
      final response = await http
          .get(Uri.parse('https://support.homofixcompany.com/api/Addons-GET/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  @override
  void initState() {
    fetchData();
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
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
      Position curruntPossition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {});

      List<Placemark> placemarks = await placemarkFromCoordinates(
        curruntPossition.latitude,
        curruntPossition.longitude,
      );
      Placemark placemark = placemarks.first;
      String locationaddress =
          '${placemark.name}, ${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';

      Map<String, dynamic> data = {
        "technician_id": widget.expertId,
        "booking_id": widget.orderId,
        "location": locationaddress
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

      if (response.statusCode == 200) {
        print("Data added successfully");
      } else {
        print("Failed to add data");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      totalPrice += product['price'];
    }
    if (widget.status == 'Assign') {
      _statusList = ['Completed'];
      _selectedStatus = 'Completed';
    } else {
      _statusList = ['--Select--', 'Completed'];
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
                                child: (widget.status == 'Completed')
                                    ? Text(
                                        widget.status,
                                        style: TextStyle(color: Colors.black),
                                      )
                                    : DropdownButton<String>(
                                        hint: Text("--Select--"),
                                        icon: Icon(FontAwesomeIcons.angleDown,
                                            color: Colors.black),
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
                                            child: Text(value),
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
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: widget.products.length + dataList.length,
                          itemBuilder: (context, index) {
                            if (index < widget.products.length) {
                              final product = widget.products[index];
                              int qnt = proSet[index]['quantity'];
                              final productName = product['name'];
                              final productTitle = product['product_title'];
                              final productPrice =
                                  product['selling_price'] * qnt;
                              final productImage = product['product_pic'];

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                      item['spare_parts_id']['description']
                                          .toString(),
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
                                          '\u20B9 ${item['spare_parts_id']['price'].toString()}',
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
                                    // Customize the ListTile according to your data structure
                                    // You can access other fields like item['field_name'] as needed
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
              print("tap");
//downloadFile();
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => MyPage()));
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
