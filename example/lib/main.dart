import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:ip_sdk/authentication_response.dart';
import 'package:ip_sdk/ip_sdk.dart';
import 'package:http/http.dart' as http;
import "dart:developer";
import 'package:jwt_decoder/jwt_decoder.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String authenCode = '';
  String alertMessage = '';
  bool coverageAvailable = false;
  final String TOKEN_URL =
      "https://stage.ipification.com/auth/realms/ipification/protocol/openid-connect/token";

  final String YOUR_CLIENT_SECRET = 'd6d710ee-68db-4913-934e-b02330523549';

  final String countryCode = "84";
  final String phoneNumber = "921744713";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPification SDK example'),
      ),
      body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('$alertMessage\n', textAlign: TextAlign.center),
                ElevatedButton(
                  child: const Text('Authenticate'),
                  onPressed: doAuthentication,
                )
              ])),
    );
  }

  @override
  void deactivate() {
    if (Platform.isAndroid) {
      IpSdk.unregisterNetwork();
    }
    super.deactivate();
  }

  Future<void> doAuthentication() async {
    String errMessage;
    try {
      setState(() {
        alertMessage = "Checking Coverage";
      });
      // if (Platform.isAndroid) {
      //   IpSdk.setAuthorizationServiceConfiguration("ipification_services");
      // }

      var coverageResult = await IpSdk.checkCoverage;
      coverageAvailable = coverageResult.isAvaiable;
      // print(coverageResult.isAvaiable);
      print("operatorCode: ${coverageResult.operatorCode}");
    } on PlatformException catch (e) {
      coverageAvailable = false;
      errMessage = e.code + "\n" + e.message;
    }
    if (coverageAvailable == true) {
      try {
        // if (Platform.isAndroid) {
        //   IpSdk.setAuthorizationServiceConfiguration("ipification_services");
        // }
        print(countryCode + phoneNumber);
        // IpSdk.addQueryParam(key: "custom_key", value: "custom_value");
        // IpSdk.setState(value: "custom_state");
        IpSdk.setScope(value: "openid");
        AuthenticationResponse authResponse =
            await IpSdk.doAuthentication(loginHint: countryCode + phoneNumber);
        authenCode = authResponse.code;
        
        print(authenCode);
        print(authResponse.state);
        print(authResponse.responseString);
        if (authenCode.isNotEmpty) {
          await doTokenExchange(
              authenCode,
              (success) => {
                    errMessage =
                        "Supported Telco : $coverageAvailable" + "\n\n",
                    errMessage = errMessage +
                        "Phone Number verified: ${success['phone_number_verified']}" +
                        "\n\n",
                    errMessage = errMessage +
                        "Authentication Result: $authenCode" +
                        "\n\n",
                    errMessage =
                        errMessage + "Access token: ${success['access_token']}"
                  },
              (fail) => {errMessage = fail});
        } else {
          errMessage = "code nil";
        }
      } on PlatformException catch (e) {
        errMessage = e.code + "\n" + e.message;
      }
    }
    print(errMessage);
    if (!mounted) return;

    setState(() {
      if (authenCode.isNotEmpty) {
        alertMessage = errMessage;
      } else {
        alertMessage = errMessage ?? 'Error: Coverage : unavailable';
      }
    });
  }

  Future<void> doTokenExchange(var authentCode,
      Function(Map<String, dynamic>) success, Function(String) fail) async {
    var clientID = await IpSdk.getConfigurationByName("client_id");
    String redirectURI = await IpSdk.getConfigurationByName("redirect_uri");
    log("client_id:$clientID");
    log("redirect_uri:$redirectURI");
    var details = {
      'client_id': clientID,
      'grant_type': 'authorization_code',
      'client_secret': YOUR_CLIENT_SECRET,
      'redirect_uri': redirectURI,
      'code': authenCode
    };
    print(details);
    var client = http.Client();
    try {
      var responseJson = await client.post(TOKEN_URL, body: details);
      // responseJson["access_token"]
      print(responseJson);
      Map<String, dynamic> parse = jsonDecode(responseJson.body);
      if (responseJson.statusCode == 200) {
        Map<String, dynamic> decodedToken =
            JwtDecoder.decode(parse["access_token"]);
        log("responseJson: ${decodedToken.toString()}");
        decodedToken["access_token"] = parse["access_token"];
        success(decodedToken);
      } else {
        fail(parse["error_description"]);
      }
    } finally {
      client.close();
    }
  }

  void nextPage() {}
}
