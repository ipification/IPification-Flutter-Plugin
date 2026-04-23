// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ipification_plugin/authentication_response.dart';
import 'package:http/http.dart' as http;
import 'package:ipification_plugin/ipification.dart';
import "dart:developer";
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final IPificationPlugin _plugin = IPificationPlugin();
  String authenCode = '';
  String alertMessage = '';
  bool coverageAvailable = false;
  final String tokenUrl =
      "https://stage.ipification.com/auth/realms/ipification/protocol/openid-connect/token";

  final String clientSecret = 'd6d710ee-68db-4913-934e-b02330523549';

  final String countryCode = "84";
  final String phoneNumber = "921744713";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IPification SDK example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, //.horizontal
              child: Text(
                '$alertMessage\n',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0, color: Colors.red),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: doAuthentication,
            child: const Text('Authenticate'),
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    if (Platform.isAndroid) {
      _plugin.unregisterNetwork();
    }
    super.deactivate();
  }

  Future<void> doAuthentication() async {
    await _plugin.enableLog();

    var errMessage = '';
    try {
      setState(() {
        alertMessage = "Checking Coverage";
      });
      // if (Platform.isAndroid) {
      //   IpSdk.setAuthorizationServiceConfiguration("ipification_services");
      // }
      await _plugin.setEnv(ENV.SANDBOX);
      if (kReleaseMode) {
        print(1);
        await _plugin.setCheckCoverageUrl(
          "https://api.ipification.com/auth/realms/ipification/coverage",
        );
        await _plugin.setAuthorizationUrl(
          "https://api.ipification.com/auth/realms/ipification/protocol/openid-connect/auth",
        );
        await _plugin.setClientId("webclient3");
        await _plugin.setRedirectUri(
          "https://api.dev.ipification.com/api/v1/callback",
        );
      } else {
        print(2);

        await _plugin.setCheckCoverageUrl(
          "https://stage.ipification.com/auth/realms/ipification/coverage2",
        );
        await _plugin.setAuthorizationUrl(
          "https://stage.ipification.com/auth/realms/ipification/protocol/openid-connect/auth",
        );
        await _plugin.setClientId("webclient3");
        await _plugin.setRedirectUri(
          "https://api.dev.ipification.com/api/v1/callback",
        );
      }

      final clientid = await _plugin.getClientId();
      print(clientid);
      final coverageResult = await _plugin.checkCoverage();
      coverageAvailable = coverageResult.isAvailable;
      final logOutput = await _plugin.getLog();
      print("log${logOutput ?? ''}");
      // print(coverageResult.isAvaiable);
      print("operatorCode: ${coverageResult.operatorCode}");
    } on PlatformException catch (e) {
      coverageAvailable = false;
      errMessage = '${e.code}\n${e.message ?? ''}';
    }

    if (coverageAvailable == true) {
      try {
        // if (Platform.isAndroid) {
        //   IpSdk.setAuthorizationServiceConfiguration("ipification_services");
        // }
        print(countryCode + phoneNumber);
        // IpSdk.addQueryParam(key: "custom_key", value: "custom_value");
        // IpSdk.setState(value: "custom_state");
        await _plugin.setScope(value: "openid");
        final AuthenticationResponse authResponse = await _plugin
            .doAuthentication(loginHint: countryCode + phoneNumber);
        authenCode = authResponse.code ?? '';

        print(authenCode);
        print(authResponse.state);
        print(authResponse.responseString);
        if (authenCode.isNotEmpty) {
          errMessage = await doTokenExchange(authenCode);
        } else {
          errMessage = "code nil";
        }
      } on PlatformException catch (e) {
        print(e);
        final logOutput = await _plugin.getLog();
        print(logOutput ?? '');
        errMessage = '${e.code}\n${e.message ?? ''}';
      }
    }
    if (!coverageAvailable && errMessage.isEmpty) {
      errMessage = 'Error: Coverage unavailable';
    }
    print(errMessage);
    if (!mounted) return;

    setState(() {
      alertMessage = errMessage;
    });
  }

  Future<String> doTokenExchange(String authentCode) async {
    final clientID = await _plugin.getClientId();
    final redirectURI = await _plugin.getRedirectUri() ?? '';
    log("client_id:$clientID");
    log("redirect_uri:$redirectURI");
    final details = {
      'client_id': clientID,
      'grant_type': 'authorization_code',
      'client_secret': clientSecret,
      'redirect_uri': redirectURI,
      'code': authenCode,
    };
    print(details);
    final client = http.Client();
    try {
      final responseJson = await client.post(
        Uri.parse(tokenUrl),
        body: details,
      );
      // responseJson["access_token"]
      print(responseJson);
      final Map<String, dynamic> parse = jsonDecode(responseJson.body);
      if (responseJson.statusCode == 200) {
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(
          parse["access_token"],
        );
        log("responseJson: ${decodedToken.toString()}");
        decodedToken["access_token"] = parse["access_token"];
        return "Supported Telco : $coverageAvailable\n\n"
            "Phone Number verified: ${decodedToken['phone_number_verified']}\n\n"
            "Authentication Result: $authenCode\n\n"
            "Access token: ${decodedToken['access_token']}";
      } else {
        return parse["error_description"]?.toString() ??
            "Token exchange failed";
      }
    } finally {
      client.close();
    }
  }

  void nextPage() {}
}
