import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homofix_expert/Adons/adonsAddlist.dart';
import 'package:homofix_expert/Custom_Widget/custom_responsive_h_w.dart';
import 'package:homofix_expert/DashBord/dashbord.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddAdomsPartScreen extends StatefulWidget {
  final String bookingStatus;

  final String expertId;

  final List<dynamic> products;
  final List<dynamic> productSet;
  final int orderId;
  AddAdomsPartScreen(
      {Key? key,
      required this.bookingStatus,
      required this.expertId,
      required this.products,
      required this.orderId,
      required this.productSet})
      : super(key: key);

  @override
  State<AddAdomsPartScreen> createState() => _AddAdomsPartScreenState();
}

class _AddAdomsPartScreenState extends State<AddAdomsPartScreen> {
  List<dynamic> addonsList = [];
  List<dynamic> dataList = [];
  List<dynamic> bookingProducts = [];
  bool isLoading = true;
  String totalAmountText = '';
  String tax = '';
  String finalamount = '';
  Timer? timer;
  Future<void> _fetchAddonsData() async {
    setState(() {
      isLoading = true;
    });

    final response = await http
        .get(Uri.parse('https://support.homofixcompany.com/api/SpareParts/'));
    if (response.statusCode == 200) {
      setState(() {
        addonsList = json.decode(response.body);
        isLoading = false;
      });
    } else {
      print('Failed to fetch data');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('https://support.homofixcompany.com/api/Addons-GET/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print(data);

      if (data is List) {
        final filteredData =
            data.where((item) => item['booking_id'] == widget.orderId).toList();

        if (filteredData.isNotEmpty) {
          setState(() {
            dataList = filteredData;
          });
        } else {
          print('No data found for the provided booking ID');
        }
      } else {
        print('Invalid data format');
      }
    } else {
      print('Failed to fetch data');
    }

    //  isLoading = false;
  }

  Future<void> updateStatus(String selectedStatus, int orderId) async {
    final url = 'https://support.homofixcompany.com/api/Task/';
    final dio = Dio();

    final response = await dio.put(
      url,
      data: {
        'booking_id': orderId,
        'status': selectedStatus,
      },
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to update status');
    }
  }

  Future<void> fetchDataAmount() async {
    final response = await http.get(Uri.parse(
        'https://support.homofixcompany.com/api/Task/?technician_id=${widget.expertId}'));

    if (response.statusCode == 200) {
      final parsedResponse = json.decode(response.body);

      final List<Map<String, dynamic>> itemsList =
          List<Map<String, dynamic>>.from(parsedResponse);

      bookingProducts = itemsList
          .where((item) => item['booking']['id'] == widget.orderId)
          .map((item) => {
                'tax_amount': item['booking']['tax_amount'],
                'total_amount': item['booking']['total_amount'],
                'final_amount': item['booking']['final_amount'],
                'pay_amt': item['booking']['pay_amt'],
                'online': item['booking']['online']
              })
          .where((bookingProduct) =>
              bookingProduct['tax_amount'] != null &&
              bookingProduct['total_amount'] != null &&
              bookingProduct['pay_amt'] != null &&
              bookingProduct['online'] != null &&
              bookingProduct['final_amount'] != null)
          .toList();

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchAddonsData();
    fetchDataAmount();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> pro = widget.products;
    List<dynamic> proSet = widget.productSet;

    for (int i = 0; i < pro.length; i++) {
      String productId = pro[i]['id'].toString();
      String productqnt = pro[i]['quantity'].toString();
      // Do something with the productId
      //  print("Rr Id : $productqnt");
    }
    for (int i = 0; i < proSet.length; i++) {
      String productName = proSet[i]['id'].toString();
      //  print("My Id : $productName");
    }
    double firstTableTotalPrice = 0.0;
    for (int i = 0; i < pro.length; i++) {
      double price = pro[i]['selling_price'].toDouble();
      int quantity = proSet[i]['quantity'];
      double realPrice = price * quantity;
      double taxPrice = realPrice * 0.18;

      double totalPriceWithTax = (price * quantity) + taxPrice;
      firstTableTotalPrice += totalPriceWithTax;
      // print("Ar----------------------- : $firstTableTotalPrice");
    }
    String formattedFirstTableTotalPrice =
        firstTableTotalPrice.toStringAsFixed(2);
    double secondTableTotalPrice = 0.0;
    for (int i = 0; i < dataList.length; i++) {
      double price = dataList[i]['spare_parts_id']['price'].toDouble();
      int quantity = dataList[i]['quantity'];
      double realPrice = price * quantity;
      // double taxPrice = realPrice * 0.18;

      double totalPriceWithTax = (price * quantity);
      secondTableTotalPrice += totalPriceWithTax;
    }
// formattedTotalPrice
    String formattedSecondTableTotalPrice =
        secondTableTotalPrice.toStringAsFixed(2);
    double overallTotalPrice = firstTableTotalPrice + secondTableTotalPrice;
    // print("Over----------------------- : $overallTotalPrice");
    String formattedOverallTotalPrice = overallTotalPrice.toStringAsFixed(2);
    var payAmount =
        bookingProducts.isNotEmpty ? bookingProducts[0]['pay_amt'] : 'N/A';
    bool online = bookingProducts.isNotEmpty
        ? bookingProducts[0]['online'] as bool? ?? false
        : false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff002790),
        title: Text(
          "Addons".toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/homofixlogo.jpg'),
                      SizedBox(
                        height: 15,
                      ),
                      Table(
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            children: [
                              TableCell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'ITEMS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'QTY',
                                    style: TextStyle(
                                                                            fontSize: 10,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'RATE',
                                    style: TextStyle(
                                                                            fontSize: 10,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Amount',
                                    style: TextStyle(
                                                                            fontSize: 10,

                                      // fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child:
                                    SizedBox(), // Empty TableCell for the delete icon
                              ),
                            ],
                          ),
                          ...List.generate(pro.length, (index) {
                            int qnt = proSet[index]['quantity'];
                            double price =
                                pro[index]['selling_price'].toDouble() * qnt;

                            //   print(qnt);
                            double taxPrice = price * 0.18;
                            double totalPriceWithTax = price;
                            double totalPrice = 0.0;
                            totalPrice += totalPriceWithTax;
                            String formattedTotalPrice =
                                totalPriceWithTax.toStringAsFixed(2);
                            //   print(formattedTotalPrice);
                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              pro[index]['name'].toUpperCase(),
                                              style: TextStyle(fontSize: 8),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddomsAddListPAge(
                                                  products: widget.products,
                                                  orderId: widget.orderId,
                                                  productId: pro[index]['id'],
                                                  proSetId: proSet[index]['id'],
                                                  proSetProduct: proSet[index]
                                                      ['product'],
                                                  bookingStatus:
                                                      widget.bookingStatus,
                                                  expertId: widget.expertId,
                                                  productSet: widget.productSet,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.yellow),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Text(
                                                '+  Addons'.toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: 7,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      '',
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      '${proSet[index]['quantity'].toString()} PCS',
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "\u20B9 ${pro[index]['selling_price'].toString()}",
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "\u20B9 ${formattedTotalPrice}",
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child:
                                      SizedBox(), // Empty TableCell for the delete icon
                                ),
                              ],
                            );
                          }),
                          ...List.generate(dataList.length, (index) {
                            double price = dataList[index]['spare_parts_id']
                                    ['price']
                                .toDouble();

                            int quantity = dataList[index]['quantity'];
                            double taxPrice = price * 0.18 * quantity;
                            String formatTax = taxPrice.toStringAsFixed(2);
                            double totalPriceWithTax = (price * quantity);
                            double totalPrice = 0.0;
                            totalPrice += totalPriceWithTax;
                            String formattedTotalPrice =
                                totalPriceWithTax.toStringAsFixed(2);
                            return TableRow(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 1,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                children: [
                                  TableCell(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Wrap(
                                      children: [
                                        Text(
                                          dataList[index]['spare_parts_id']
                                                  ['spare_part']
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(fontSize: 8),
                                        ),
                                      ],
                                    ),
                                  )),
                                  TableCell(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "",
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  )),
                                  TableCell(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "${dataList[index]['quantity'].toString()}PCS",
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  )),
                                  TableCell(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "\u20B9 ${dataList[index]['spare_parts_id']['price'].toString()}",
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  )),
                                  TableCell(
                                      child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "\u20B9 $formattedTotalPrice",
                                      style: TextStyle(fontSize: 8),
                                    ),
                                  )),
                                  TableCell(
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirmation'),
                                              content: Text(
                                                  'Are you sure you want to delete this item?'),
                                              actions: [
                                                TextButton(
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      final url =
                                                          'https://support.homofixcompany.com/api/Addons/Delete';
                                                      final response =
                                                          await http.delete(
                                                        Uri.parse(url),
                                                        headers: {
                                                          'Content-Type':
                                                              'application/json',
                                                        },
                                                        body: jsonEncode({
                                                          'id': dataList[index]
                                                              ['id'],
                                                        }),
                                                      );

                                                      if (response.statusCode ==
                                                          200) {
                                                        setState(() {
                                                          dataList
                                                              .removeAt(index);
                                                        });
                                                        Navigator.pop(context);
                                                        fetchDataAmount(); // Call fetchDataAmount() function here
                                                      } else {
                                                        // Handle the error response
                                                        print(
                                                            'Failed to delete item. Status code: ${response.statusCode}');
                                                      }
                                                    } catch (error) {
                                                      print(
                                                          'Failed to delete item: $error');
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ]);
                          }),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text("sub price".toUpperCase())),
                                    Text(
                                      '${bookingProducts.isNotEmpty ? bookingProducts[0]['total_amount'] : 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text("Tax".toUpperCase())),
                                    Text(
                                      '${bookingProducts.isNotEmpty ? bookingProducts[0]['tax_amount'] : 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height: .5,
                                  color: Colors.black,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Total ".toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      '${bookingProducts.isNotEmpty ? bookingProducts[0]['final_amount'] : 'N/A'}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height: .5,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: GestureDetector(
          onTap: () {
            if (payAmount != 0 && online == true) {
              Fluttertoast.showToast(
                msg: 'Refreshing....',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              fetchDataAmount();

              return;
            }

            updateStatus('Completed', widget.orderId).then((value) =>
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => DashBord()),
                    (route) => false));
            Fluttertoast.showToast(
              msg: "Proceed successful",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          },
          child: Container(
            height: getMediaQueryHeight(context: context, value: 45),
            // color: Color(0xff002790),
            color: payAmount != 0 && online == true
                ? Colors.green
                : Color(0xff002790),
            child: Center(
              child: Text(
                payAmount != 0 && online == true
                    ? 'Refresh for Payment'
                    : 'Proceed',
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
