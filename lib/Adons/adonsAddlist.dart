import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:homofix_expert/Adons/adonsAdd.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddomsAddListPAge extends StatefulWidget {
  final List<dynamic> products;
  final String bookingStatus;

  final String expertId;

  final List<dynamic> productSet;
  final int orderId;
  final int productId;
  final int proSetId;
  final int proSetProduct;
  AddomsAddListPAge({
    Key? key,
    required this.proSetProduct,
    required this.bookingStatus,
    required this.expertId,
    required this.products,
    required this.orderId,
    required this.proSetId,
    required this.productId,
    required this.productSet,
  }) : super(key: key);

  @override
  State<AddomsAddListPAge> createState() => _AddomsAddListPAgeState();
}

class _AddomsAddListPAgeState extends State<AddomsAddListPAge> {
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  final _qtyController = TextEditingController(text: '1');
  final descController = TextEditingController();

  List<dynamic> addonsList = [];
  List<Map<String, dynamic>> _spareParts = [];

  String? _selectedSparePart;

  Future<List<Map<String, dynamic>>> fetchSpareParts() async {
    final response = await http
        .get(Uri.parse('https://support.homofixcompany.com/api/SpareParts/'));
    final data = json.decode(response.body);

    final List<Map<String, dynamic>> spareParts =
        List<Map<String, dynamic>>.from(data);

    final filteredSpareParts = spareParts
        .where((part) => widget.productId == part['product'])
        .toList();

    return filteredSpareParts;
  }

  void _getSpareParts() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    final List<Map<String, dynamic>> data = await fetchSpareParts();
    setState(() {
      _spareParts = data;
      _isLoading = false; // Set loading state to false after data is fetched
    });
  }

  Future<void> postAddon() async {
    final spareParts = await fetchSpareParts();

    final url = Uri.parse('https://support.homofixcompany.com/api/Addons/');
    final headers = {'Content-Type': 'application/json'};

    final id = _selectedSparePart;
    String? _selectedProductId;

    for (int i = 0; i < widget.products.length; i++) {
      if (widget.products[i]['id'].toString() ==
          _selectedProductId.toString()) {
        break;
      }
    }
    final data = json.encode({
      "quantity": _qtyController.text,
      "date": DateTime.now().toString(),
      "description": descController.text,
      "booking_prod_id": widget.proSetId,
      "spare_parts_id": id,
    });

    try {
      final response = await http.post(url, headers: headers, body: data);

      if (response.statusCode == 201) {
        // post was successful
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        // handle errors
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // handle exceptions
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _getSpareParts();
    print(widget.orderId);
    print(widget.proSetProduct);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    descController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff002790),
        title: Text(
          "Add Addons".toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Text(widget.productId.toString()),
                    // Text(widget.proSetId.toString()),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 0.05,
                                    blurRadius: 3,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(9)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              child: Center(
                                child: DropdownButton<String>(
  icon: Icon(FontAwesomeIcons.angleDown, color: Colors.black),
  hint: Text("Select"),
  underline: Container(height: 0),
  iconSize: 18,
  iconEnabledColor: Colors.black,
  isDense: true,
  isExpanded: true,
  value: _selectedSparePart,
  onChanged: (value) {
    setState(() {
      _selectedSparePart = value;
      _isButtonEnabled = true;
    });
  },
  items: _spareParts.asMap().map((index, sparePart) {
    final String id = sparePart['id'].toString();
    final String name = sparePart['spare_part'].toString();
    
    return MapEntry(
      index,
      DropdownMenuItem<String>(
        value: id,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: index == _spareParts.length - 1 ? Colors.transparent : Colors.grey, // Hide border for last item
                width: 1.0,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), 
            child: Text(
              name.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                // decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }).values.toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            //  height: getMediaQueryHeight(context: context, value: 50),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 0.05,
                                    blurRadius: 3,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(9)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                controller: _qtyController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "QTY",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 0.05,
                            blurRadius: 3,
                          )
                        ],
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: descController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Description",
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Color(0xFFBDBABA);
                                  }
                                  return Color(0xff002790);
                                },
                              ),
                            ),
                            onPressed: _isButtonEnabled
                                ? () async {
                                    setState(() {
                                      _isLoading =
                                          true; // set isLoading to true to show CircularProgressIndicator
                                    });
                                    await postAddon();
                                    descController.clear();
                                    _selectedSparePart = null;
                                    setState(() {
                                      _isButtonEnabled = false;
                                      _isLoading =
                                          false; // set isLoading to false to hide CircularProgressIndicator
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddAdomsPartScreen(
                                            products: widget.products,
                                            orderId: widget.orderId,
                                            bookingStatus: widget.bookingStatus,
                                            expertId: widget.expertId,
                                            productSet: widget.productSet,
                                          ),
                                        ));
                                  }
                                : null,
                            child: Text(
                              'Add Addons',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        if (_isLoading) // show CircularProgressIndicator if isLoading is true
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // CustomContainerMediamButton(
                    //   buttonText: 'Add Product',
                    //   onTap: () async {
                    //     await postAddon();
                    //     descController.clear();
                    //     _selectedSparePart = null;
                    //   },
                    // )
                  ],
                ),
              ),
            ),
    );
  }
}
