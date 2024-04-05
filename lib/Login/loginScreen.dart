import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:homofix_expert/Custom_Widget/custom_text_style.dart';
import 'package:homofix_expert/DashBord/dashbord.dart';
import 'package:homofix_expert/JoinExpert/join.dart';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _showPassword = false;
  bool isLoading = false;
  var isDeviceConnected = false;
  bool isAlertSet = false;
  late StreamSubscription subscription;
  bool privacyPolicyChecked = false;

  int? state = 0;
  final formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController(
      //   text: 'demo795'
      );
  final TextEditingController _password = TextEditingController(
      //  text: 'demo123'
      );

  Future<void> _login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('https://support.homofixcompany.com/api/Login/');
    final body = {
      'username': _email.text.trim(),
      'password': _password.text.trim(),
      // 'username': 'demo795',
      // 'password': 'demo123',
    };

    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final user = jsonResponse['user'];
        final id = user['id'];
        final email = user['email'];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', _email.text);
        prefs.setString('id', id.toString());
        prefs.setString('email', email.toString());
        prefs.setBool('loggedIn', true);

        final expertUrl =
            Uri.parse('https://support.homofixcompany.com/api/Expert/$id/');
        final expertResponse = await http.get(expertUrl);

        if (expertResponse.statusCode == 200) {
          final expertJsonResponse = json.decode(expertResponse.body);
          final expertStatus = expertJsonResponse['status'];

          if (expertStatus == 'Hold') {
            Fluttertoast.showToast(
              msg: "Your account is on hold, please contact support",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else if (expertStatus == 'Inactive') {
            Fluttertoast.showToast(
              msg: "Your account has been Deteted please contact support",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            Fluttertoast.showToast(
              msg: "Login successful",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            bool loggedIn = prefs.getBool('loggedIn') ?? false;
            if (loggedIn) {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => DashBord()),
              );
            } else {
              // Handle the case when the user logs in for the first time
            }
          }
        } else {
          Fluttertoast.showToast(
            msg: "Error checking expert status",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Invalid username or password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred, please try again later",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLoggedInStatus();
  }

  void _checkLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('loggedIn') ?? false;

    if (loggedIn) {
      // User is already logged in, navigate to dashboard
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => DashBord()),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: Image.asset("assets/blob.png")),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(top: 180, left: 30),
                        child: GradientText("Login",
                            // ignore: prefer_const_literals_to_create_immutables
                            gradient: LinearGradient(colors: [
                              Color(0xff002790),
                              Color.fromARGB(255, 14, 60, 187)
                            ]),
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87))),
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8.0, left: 30, right: 30),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Username',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Color(0xffa3a5ad), fontSize: 18),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Material(
                            borderRadius: BorderRadius.circular(10.0),
                            elevation: 2,
                            color: Colors.white,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter userId';
                                    }
                                    return null;
                                  },
                                  controller: _email,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 14.0),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Color(0xffa3a5ad),
                                    ),
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Password',
                                style: TextStyle(
                                    color: Color(0xffa3a5ad), fontSize: 18),
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          Material(
                            elevation: 3,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                obscureText: !_showPassword,
                                controller: _password,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    color: Colors.grey,
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.only(top: 14.0),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Color(0xffa3a5ad),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => MyJoin()));
                                },
                                child: const Text(
                                  'Join as Expert?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF646464)),
                                ),
                              ),
                              TextButton(
                                autofocus: true,
                                child: Text(
                                  'Joinnow',
                                  style: customSmallTextStyle,
                                  textAlign: TextAlign.right,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const MyJoin()),
                                  );
                                },
                              ),
                            ],
                          ),
                          ListTile(
                            minVerticalPadding: 0,
                            horizontalTitleGap: 0,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Checkbox(
                              activeColor: const Color(0xff002790),
                              value: privacyPolicyChecked,
                              onChanged: (value) {
                                setState(() {
                                  privacyPolicyChecked = value!;
                                });
                              },
                            ),
                            title: RichText(
                                text: TextSpan(
                              text:
                                  'By creating an account you specify that you have read and agree with our ',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: 'Terms of Use',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Color(0xff002790),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchURL(
                                          'https://www.homofixcompany.com/terms');
                                      // if (kDebugMode) {
                                      //   print('Terms of Use clicked');
                                      // }
                                      // You can navigate to the Terms of Use page or open a dialog, etc.
                                    },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Color(0xff002790),
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchURL(
                                          'https://www.homofixcompany.com/privacy');
                                    },
                                ),
                              ],
                            )),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () async {
                                if (privacyPolicyChecked == true) {
                                  if (formKey.currentState!.validate()) {
                                    await _login(context);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'Please accept both privacy policy and terms & conditions.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              //   if (formKey.currentState!.validate()) {
                              //     await _login(context);
                              //   }
                              // },
                              child: Container(
                                  height: 50,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(
                                      colors: [
                                        (privacyPolicyChecked)
                                            ? const Color(0xff002790)
                                            : Colors
                                                .grey, // Use grey if not checked
                                        (privacyPolicyChecked)
                                            ? const Color(0xff002790)
                                            : Colors
                                                .grey, // Use grey if not checked
                                      ],
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ))
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                'Login ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget setUpButtonChild() {
    if (state == 0) {
      return const Text(
        "Update Profile",
      );
    } else if (state == 1) {
      return const CircularProgressIndicator(
        color: Colors.white,
      );
    } else {
      Timer(const Duration(seconds: 2), () {
        setState(() {
          state = 0;
        });
      });
      return const Text(
        "Updated",
        // style: GoogleFonts.outfit(
        //     color: Color(0xffffffff),
        //     fontSize: 20,
        //     fontWeight: FontWeight.w500),
      );
    }
  }

//   showDialogBox(context) {
//     showCupertinoDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CupertinoAlertDialog(
//           title: const Text("No Connection"),
//           content: const Text("Please check your internet connectivity"),
//           actions: [
//             CupertinoDialogAction(
//               child: const Text("OK"),
//               onPressed: () async {
//                 Navigator.pop(context, 'cancel');
//                 setState(() => isAlertSet = false);

//                 isAlertSet = false;
//                 isDeviceConnected =
//                     await InternetConnectionChecker().hasConnection;
//                 if (!isDeviceConnected) {
//                   showDialogBox(context);
//                   setState(() {
//                     isAlertSet = true;
//                   });
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
