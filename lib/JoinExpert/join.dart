import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homofix_expert/Custom_Widget/custom_medium_button.dart';
import 'package:homofix_expert/Custom_Widget/custom_responsive_h_w.dart';
import 'package:file_picker/file_picker.dart';

class MyJoin extends StatefulWidget {
  const MyJoin({Key? key}) : super(key: key);

  @override
  State<MyJoin> createState() => _MyJoinState();
}

class _MyJoinState extends State<MyJoin> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController expertTypeController = TextEditingController();
  TextEditingController fullAddressController = TextEditingController();
  String? _pdfPath;

  ///File? _imageFile;
  var _pdfFile;
  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff002790),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Career",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
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
                      validator: (value) {
                        // add a validator function
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Name",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: getMediaQueryHeight(context: context, value: 15),
                ),
                Container(
                  width: double.infinity,
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
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your mobile no';
                        }

                        String sanitizedValue = value.replaceAll(
                            RegExp(r'\s+'), ''); // Remove whitespace
                        if (sanitizedValue.length != 10) {
                          return 'Mobile number should be exactly 10 digits';
                        }

                        return null;
                      },
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        hintText: "Mobile",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: getMediaQueryHeight(context: context, value: 15),
                ),
                Container(
                  width: double.infinity,
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
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Email",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: getMediaQueryHeight(context: context, value: 15),
                ),
                Container(
                  width: double.infinity,
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
                      validator: (value) {
                        // add a validator function
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Type';
                        }
                        return null;
                      },
                      controller: expertTypeController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Expert Type",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: getMediaQueryHeight(context: context, value: 15),
                ),
                Container(
                  width: double.infinity,
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
                      validator: (value) {
                        // add a validator function
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Full Address';
                        }
                        return null;
                      },
                      controller: fullAddressController,
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Full addrees",
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: getMediaQueryHeight(context: context, value: 15),
                ),
                DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(12),
                  padding: EdgeInsets.all(6),
                  child: InkWell(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                      if (result != null) {
                        PlatformFile file = result.files.first;
                        setState(() {
                          _pdfFile = File(file.path!);
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      color: Color(0xFFF2FA95).withOpacity(0.5),
                      child: Column(
                        children: [
                          _pdfFile != null
                              ? Text(
                                  _pdfFile.path,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFCCCBCB),
                                  ),
                                )
                              : Icon(
                                  Icons.upload_file,
                                  size: 30,
                                  color: Color(0xFFCCCBCB),
                                ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              _pdfFile == null
                                  ? "Upload Your PDF"
                                  : "Selected PDF: ${_pdfFile.path}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFCCCBCB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: getMediaQueryHeight(context: context, value: 15),
                ),
                CustomContainerMediamButton(
                  buttonText: 'Submit',
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      onTap();
                      setState(() {
                        Navigator.pop(context);
                      });
                    }
                  },
                )
              ],
            ),
          ),
        ),
      )),
    );
  }

  void onTap() async {
    FormData formData = FormData.fromMap({
      "name": nameController.text,
      "email": emailController.text,
      "mobile": mobileController.text,
      "expert_in": expertTypeController.text,
      "full_address": fullAddressController.text,
    });

    if (_pdfFile != null) {
      formData.files.add(MapEntry(
        "resume",
        await MultipartFile.fromFile(_pdfFile!.path,
            filename: _pdfFile!.path.split('/').last),
      ));
    }

    Dio dio = Dio();
    Response response = await dio.post(
      'https://support.homofixcompany.com/api/JobEnquiry/',
      data: formData,
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Form Upload successful, Contact soon",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Form errors",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
