import 'package:flutter/material.dart';
import 'package:send_sms/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          settingsTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              defaultSentMessageApp,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
            ),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Handle switch state change
              },
            ),
          ),
          ListTile(
            onTap: () async {
              if (!await launchUrl(Uri.parse(privacyPolicyLink))) {
                throw Exception('Could not launch $privacyPolicyLink');
              }
            },
            title: Text(privacyPolicyTitle),
            leading: Icon(Icons.security_outlined, color: Colors.black),
          ),
          ListTile(
            onTap: () async {
              if (!await launchUrl(Uri.parse(buyMeACoffeeLink))) {
                throw Exception('Could not launch $buyMeACoffeeLink');
              }
            },
            title: Text(
              buyMeACoffeeTitle,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: Image.asset(
              'assets/icons/buy_me_a_coffee_icon.png',
              width: 28.0,
              height: 28.0,
              fit: BoxFit.contain,
            ),
          ),
          ListTile(
            title: Text(
              appVersion,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
