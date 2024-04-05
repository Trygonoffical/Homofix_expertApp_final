import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Contactus extends StatefulWidget {
  const Contactus({Key? key}) : super(key: key);

  @override
  State<Contactus> createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchPhoneNumber(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    final String phoneUrl = phoneUri.toString();

    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Contact Us",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff002790),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text('Reach out to us in various ways !'),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFE6E3F7),
                child: Icon(
                  FontAwesomeIcons.phone,
                  color: Color(0xff002790),
                  size: 20,
                ),
              ),
              title: Text('Contact Us: ',
                  style: TextStyle(
                      color: Color(0xff1b213c), fontWeight: FontWeight.bold)),
              subtitle: Text(
                '+91-813-0105-760',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xff1b213c),
                    fontWeight: FontWeight.normal),
              ),
              onTap: () {
                launchPhoneNumber('8130105760');
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFE6E3F7),
                child: Icon(Icons.email, color: Color(0xff002790)),
              ),
              title: Text('Email us on: ',
                  style: TextStyle(
                      color: Color(0xff1b213c), fontWeight: FontWeight.bold)),
              subtitle: Text('info@homofixcompany.com',
                  style: TextStyle(
                      color: Color(0xff1b213c), fontWeight: FontWeight.normal)),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFE6E3F7),
                child: Icon(FontAwesomeIcons.internetExplorer,
                    color: Color(0xff002790)),
              ),
              title: Text('Visit Our Website: ',
                  style: TextStyle(
                      color: Color(0xff1b213c), fontWeight: FontWeight.bold)),
              subtitle: Text(
                'www.homofixcompany.com',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xff1b213c),
                    fontWeight: FontWeight.normal),
              ),
              onTap: () {
                _launchURL('https://www.homofixcompany.com/');
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFE6E3F7),
                child:
                    Icon(FontAwesomeIcons.thumbsUp, color: Color(0xff002790)),
              ),
              title: Text('Follow Us On',
                  style: TextStyle(
                      color: Color(0xff1b213c), fontWeight: FontWeight.bold)),
              subtitle: Row(
                children: [
                  InkWell(
                    onTap: () => _launchURL(
                        'https://www.linkedin.com/company/homofix-in/'),
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFE6E3F7),
                      child: Icon(FontAwesomeIcons.linkedin,
                          size: 18, color: Color(0xff002790)),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () => _launchURL(
                        'https://instagram.com/homofixcompany?igshid=MzNlNGNkZWQ4Mg=='),
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFE6E3F7),
                      child: Icon(FontAwesomeIcons.instagram,
                          size: 18, color: Color(0xff002790)),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () => _launchURL(
                        'https://www.facebook.com/Homerepairingandservices'),
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFE6E3F7),
                      child: Icon(FontAwesomeIcons.facebook,
                          size: 18, color: Color(0xff002790)),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFE6E3F7),
                child: Icon(
                  FontAwesomeIcons.comment,
                  color: Color(0xff002790),
                  size: 20,
                ),
              ),
              title: Text('View more support...',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Color(0xff1b213c),
                      fontWeight: FontWeight.bold)),
              onTap: () {
                _launchURL('https://www.homofixcompany.com/contactus');
              },
            ),
          ],
        ),
      ),
    );
  }
}
