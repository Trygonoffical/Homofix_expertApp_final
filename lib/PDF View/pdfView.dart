import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

final pdfUrl = "";

//String pp = '';
var dio = Dio();

class Pdf_download extends StatefulWidget {
  final int orderId;

  const Pdf_download({Key? key, required this.orderId}) : super(key: key);
  @override
  _Pdf_downloadState createState() => _Pdf_downloadState();
}

class _Pdf_downloadState extends State<Pdf_download> {
  bool isLoading = true;
  bool showProgressIndicator = false;

  String pdf_file_path = '';
  void fetchData() async {
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

  Future<String> _findLocalPath() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (status.isGranted) {
        Directory? directory = await getExternalStorageDirectory();
        String path = '${directory!.path}/homofix_invoice/';
        if (!await Directory(path).exists()) {
          await Directory(path).create(recursive: true);
        }
        return path;
      } else {
        var result = await Permission.storage.request();
        if (result.isGranted) {
          Directory? directory = await getExternalStorageDirectory();
          String path = '${directory!.path}/homofix_invoice/';
          if (!await Directory(path).exists()) {
            await Directory(path).create(recursive: true);
          }
          return path;
        } else {
          throw Exception('Storage permission not granted');
        }
      }
    } else if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (status.isGranted) {
        var directory = await getApplicationDocumentsDirectory();
        return '${directory.path}${Platform.pathSeparator}';
      } else {
        var result = await Permission.photos.request();
        if (result.isGranted) {
          var directory = await getApplicationDocumentsDirectory();
          return '${directory.path}${Platform.pathSeparator}';
        } else {
          throw Exception('Photos permission not granted');
        }
      }
    } else {
      throw Exception('Unsupported platform');
    }
  }

  void openPDF() {
    if (pdf_file_path.isNotEmpty) {
      Future.delayed(const Duration(seconds: 0), () async {
        final result = await OpenFile.open(pdf_file_path);
        print(result.message);
        print(result.type);
      });
    }
  }

  Future<void> _pdfButtonClicked() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ), // Circular progress indicator
                SizedBox(height: 16),
                Text(
                  'Downloading...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );

    var localPath = await _findLocalPath();
    await download_PDF_from_url(dio, pdf_file_path, localPath);

    Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
  }

  void _pdfButtonClicked2() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(height: 16),
                Text(
                  ' Please Wait...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );

    var localPath = await _findLocalPath();
    await download_PDF_from_url(dio, pdf_file_path, localPath);

    Navigator.of(context, rootNavigator: true).pop(); // Close the dialog

    // Open the PDF
    openPDF();
  }

  Future download_PDF_from_url(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return (status ?? 0) < 500;
            }),
      );
      var finalPath = savePath + "Your Invoice.pdf";
      File file = File(finalPath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      print(savePath);
      await raf.close();
      setState(() {
        pdf_file_path = file.path.toString();
      });

      Fluttertoast.showToast(
          msg: "Pdf downloaded successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff002790),
        title: Text(
          "Your Invoice".toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        elevation: 4,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.black,
            ))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      splashColor: Colors.grey,
                      onTap: () {
                        _launchURL(pdf_file_path);
                      }, // button pressed
                      child: Row(
                        children: [
                          Text(
                            "Click to download invoice",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 22,
                                color: Color(0xff002790),
                                decoration: TextDecoration.underline),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox.fromSize(
                            size: Size(25, 25), // button width and height
                            child: ClipOval(
                              child: Material(
                                color: Color(0xff002790), // button color
                                child: InkWell(
                                  splashColor: Colors.grey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.download,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
            ),
    );
  }
}
