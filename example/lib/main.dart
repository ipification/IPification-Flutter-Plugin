import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:ipification_plugin/authentication_response.dart';
import 'package:http/http.dart' as http;
import 'package:ipification_plugin/ipification.dart';
import "dart:developer";
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart';

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
      body: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
            new Expanded(
              flex: 1,
              child: new SingleChildScrollView(
                scrollDirection: Axis.vertical, //.horizontal
                child: new Text(
                  '$alertMessage\n',
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
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
      IPificationPlugin.unregisterNetwork();
    }
    super.deactivate();
  }

  Future<void> doAuthentication() async {
    IPificationPlugin.enableLog();

    String errMessage;
    try {
      setState(() {
        alertMessage = "Checking Coverage";
      });
      // if (Platform.isAndroid) {
      //   IpSdk.setAuthorizationServiceConfiguration("ipification_services");
      // }
      IPificationPlugin.setEnv(ENV.SANDBOX);
      if (kReleaseMode) {
        print(1);
        IPificationPlugin.setCheckCoverageUrl(
            "https://api.ipification.com/auth/realms/ipification/coverage");
        IPificationPlugin.setAuthorizationUrl(
            "https://api.ipification.com/auth/realms/ipification/protocol/openid-connect/auth");
        IPificationPlugin.setClientId("webclient3");
        IPificationPlugin.setRedirectUri(
            "https://api.dev.ipification.com/api/v1/callback");
      } else {
        print(2);

        IPificationPlugin.setCheckCoverageUrl(
            "https://stage.ipification.com/auth/realms/ipification/coverage2");
        IPificationPlugin.setAuthorizationUrl(
            "https://stage.ipification.com/auth/realms/ipification/protocol/openid-connect/auth");
        IPificationPlugin.setClientId("webclient3");
        IPificationPlugin.setRedirectUri(
            "https://api.dev.ipification.com/api/v1/callback");
      }

      var clientid = await IPificationPlugin.getClientId();
      print(clientid);
      var coverageResult = await IPificationPlugin.checkCoverage();
      coverageAvailable = coverageResult.isAvailable;
      var log = await IPificationPlugin.getLog();
      print("log" + log);
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
        IPificationPlugin.setScope(value: "openid");
        AuthenticationResponse authResponse =
            await IPificationPlugin.doAuthentication(
                loginHint: countryCode + phoneNumber);
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
        print(e);
        var log = await IPificationPlugin.getLog();
        print(log);
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
    var clientID = await IPificationPlugin.getConfigurationByName("client_id");
    String redirectURI =
        await IPificationPlugin.getConfigurationByName("redirect_uri");
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
      var responseJson = await client.post(Uri.parse(TOKEN_URL), body: details);
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
