import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:send_sms/constants/app_constants.dart';
import 'package:send_sms/featres/settings/bloc/settings_bloc.dart';
import 'package:send_sms/featres/settings/bloc/settings_event.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isDefaultSMSApp = false;

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
            leading: Icon(Icons.message_outlined, color: Colors.blue),
            title: Text(
              defaultSentMessageApp,
              style: TextStyle(fontSize: 15.0, color: Colors.black),
            ),
            trailing: Switch(
              value: isDefaultSMSApp,
              onChanged: (value) {
                setState(() {
                  isDefaultSMSApp = value;
                  BlocProvider.of<SettingsBloc>(
                    context,
                  ).add(RequestDefaultSMSAppEvent());
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.widgets, color: Colors.green),
            title: Text(
              "addHomeScreenWidget",
              style: TextStyle(fontSize: 15.0, color: Colors.black),
            ),
            onTap: () {
              HomeWidget.requestPinWidget(androidName: 'CallLogsAppWidget');
            },
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
