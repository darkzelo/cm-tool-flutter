// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_text_field/style.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:otp_text_field/otp_text_field.dart';
import 'constants.dart' as Constants;

void main() {
  runApp(const MaterialApp(
    title: 'CM Tools Demo',
    home: HomePage(),
  ));
}

class Token {
  final String accessToken;
  const Token(this.accessToken);
}

class OtpDetail {
  final String mobileNo;
  final String refCode;
  const OtpDetail(this.mobileNo, this.refCode);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('App Manager'),
      ),
      body: const Center(
        child: LoginUsernamePage(),
      ),
    );
  }
}

class LoginUsernamePage extends StatelessWidget {
  const LoginUsernamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  Constants.PAGE_HEADER,
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: LoginUsernameFormWidget()),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  Constants.OR,
                  style: TextStyle(fontSize: 16),
                )),
            Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(Constants.LOGIN_WITH_OTP),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginMobileNoPage(),
                      ),
                    );
                  },
                )),
          ],
        ));
  }
}

class LoginUsernameFormWidget extends StatefulWidget {
  const LoginUsernameFormWidget({super.key});

  @override
  State<LoginUsernameFormWidget> createState() =>
      _LoginUsernameFormWidgetState();
}

class _LoginUsernameFormWidgetState extends State<LoginUsernameFormWidget> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'User Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอก Username';
                }
                return null;
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextFormField(
              obscureText: true,
              controller: passwordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอก Password';
                }
                return null;
              },
            ),
          ),
          Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(Constants.LOGIN_WITH_USERNAME),
                onPressed: () async {
                  callLogin(nameController.text, passwordController.text);
                },
              )),
        ],
      ),
    );
  }

  void callLogin(String username, String password) async {
    if (_formKey.currentState!.validate()) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Processing Data')),
      // );

      Map data = {
        "client_id": "test",
        "client_secret": "test",
        "grant_type": "password",
        "password": password,
        "username": username
      };
      //encode Map to JSON
      var body = json.encode(data);
      var url = Uri.https(
          'staging-pos-api.devfullteam.tech', 'staff-service/OAuth/token');
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);

      var statusCode = response.statusCode;
      var responseBody = response.body;

      if (statusCode == 200) {
        final responseBodyObj = json.decode(responseBody);
        if (responseBodyObj["access_token"] != "") {
          var accessToken = responseBodyObj["access_token"];
          Map data = {
            "token": accessToken,
          };
          //encode Map to JSON
          var body = json.encode(data);
          var url = Uri.https(
              Constants.API_ENDPOINT, 'staff-service/user/save-auth-session');

          var response = await http.post(url,
              headers: {
                "Content-Type": "application/json",
                'Authorization': 'Bearer $accessToken'
              },
              body: body);

          var statusCode = response.statusCode;
          var responseBody = response.body;
          if (statusCode == 200) {
            final responseBodyObj = json.decode(responseBody);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WebViewPage(token: Token(responseBodyObj["session_id"])),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(Constants.INCORRECT_USERNAME_OR_PASSWORD),
                backgroundColor: Colors.orange,
              ),
            );
          }

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => WebViewPage(
          //         token: Token(
          //             responseBodyObj["access_token"])),
          //   ),
          // );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(Constants.INCORRECT_USERNAME_OR_PASSWORD),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(Constants.INCORRECT_USERNAME_OR_PASSWORD),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

class WebViewPage extends StatelessWidget {
  const WebViewPage({super.key, required this.token});

  final Token token;

  @override
  Widget build(BuildContext context) {
    WebViewController? _controller;
    String accessToken = token.accessToken;
    String webviewEndpoint = Constants.WEBVIEW_ENDPOINT;
    return Scaffold(
      appBar: AppBar(
        title: const Text("CM Tool Management"),
        automaticallyImplyLeading: false,
      ),
      body: WebView(
        zoomEnabled: false,
        initialUrl: '$webviewEndpoint/session-auth?session_id=$accessToken',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
              // content: const Text('AlertDialog description'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => {Navigator.pop(context, 'Cancel')},
                  child: const Text('ยกเลิก'),
                ),
                TextButton(
                  onPressed: () => {
                    // Navigator.pop(context, 'OK')
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    )
                  },
                  child: const Text('ยืนยัน'),
                ),
              ],
            ),
          )
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}

class LoginMobileNoPage extends StatelessWidget {
  const LoginMobileNoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("App Manager"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    Constants.PAGE_HEADER,
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 30),
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: LoginMobileNoFormWidget()),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    Constants.OR,
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ลงชื่อเข้าใช้ด้วยอีเมล'),
                  )),
            ])));
  }
}

class LoginMobileNoFormWidget extends StatefulWidget {
  const LoginMobileNoFormWidget({super.key});

  @override
  State<LoginMobileNoFormWidget> createState() =>
      _LoginMobileNoFormWidgetState();
}

class _LoginMobileNoFormWidgetState extends State<LoginMobileNoFormWidget> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    TextEditingController mobileNoController = TextEditingController();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: mobileNoController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกหมายเลขโทรศัพท์';
                  }
                  if (value.length != 9 && value.length != 10) {
                    return 'รูปแบบหมายเลขโทรศัพท์ไม่ถูกต้อง';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'หมายเลขโทรศัพท์',
                    prefixText: "+66"),
              )),
          Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                  onPressed: () {
                    callRequestOtp(mobileNoController.text);
                    // if (_formKey.currentState!.validate()) {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => OtpPage(
                    //         otpDetail: OtpDetail(mobileNoController.text, ""),
                    //       ),
                    //     ),
                    //   );
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ขอรหัส OTP')))
        ],
      ),
    );
  }

  void callRequestOtp(String mobileNo) async {
    if (_formKey.currentState!.validate()) {
      String referenceCode = "";
      Map data = {"country_code": "+66", "tel": mobileNo};
      //encode Map to JSON
      var body = json.encode(data);
      var url = Uri.https('staging-pos-api.devfullteam.tech',
          'staff-service/onboard/request-otp');
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);

      var statusCode = response.statusCode;
      var responseBody = response.body;
      if (statusCode == 200) {
        final responseBodyObj = json.decode(responseBody);

        if (responseBodyObj["message"] == Constants.SUCCESS) {
          referenceCode = responseBodyObj["reference_code"];
          if (referenceCode != "") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpPage(
                  otpDetail: OtpDetail(mobileNo, referenceCode),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(Constants.INTERNAL_SERVER_ERROR_MSG)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(Constants.INTERNAL_SERVER_ERROR_MSG)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Constants.INTERNAL_SERVER_ERROR_MSG)),
        );
      }
    }
  }
}

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.otpDetail});
  final OtpDetail otpDetail;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  Widget build(BuildContext context) {
    String mobileNo = widget.otpDetail.mobileNo;
    String refCode = widget.otpDetail.refCode;
    OtpFieldController otpController = OtpFieldController();
    String otpValue = "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Manager"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  Constants.PAGE_HEADER,
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'ยืนยันรหัส OTP',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20),
                )),
            Container(
                alignment: Alignment.center,
                child: Text(
                  'รหัสยืนยันส่งไปที่ +66$mobileNo',
                  style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 15),
                )),
            Container(
                alignment: Alignment.center,
                child: Text(
                  'Ref Code: $refCode',
                  style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 15),
                )),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: OtpFormWidget(
                  otpDetail: OtpDetail(mobileNo, refCode),
                ))
          ])),
    );
  }
}

// class OtpPage extends StatelessWidget {
//   const OtpPage({super.key, required this.otpDetail});
//   final OtpDetail otpDetail;

//   @override
//   Widget build(BuildContext context) {
//     String mobileNo = otpDetail.mobileNo;
//     String refCode = otpDetail.refCode;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("App Manager"),
//       ),
//       body: Padding(
//           padding: const EdgeInsets.all(10),
//           child: ListView(children: <Widget>[
//             Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: const Text(
//                   Constants.PAGE_HEADER,
//                   style: TextStyle(
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 30),
//                 )),
//             Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: const Text(
//                   'ยืนยันรหัส OTP',
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 20),
//                 )),
//             Container(
//                 alignment: Alignment.center,
//                 child: Text(
//                   'รหัสยืนยันส่งไปที่ +66$mobileNo',
//                   style: const TextStyle(
//                       color: Colors.grey,
//                       fontWeight: FontWeight.w400,
//                       fontSize: 15),
//                 )),
//             Container(
//                 alignment: Alignment.center,
//                 child: Text(
//                   'Ref Code: $refCode',
//                   style: const TextStyle(
//                       color: Colors.grey,
//                       fontWeight: FontWeight.w400,
//                       fontSize: 15),
//                 )),
//             Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(10),
//                 child: OtpFormWidget(
//                   otpDetail: OtpDetail(otpDetail.mobileNo, otpDetail.refCode),
//                 ))
//           ])),
//     );
//   }
// }

class OtpFormWidget extends StatefulWidget {
  const OtpFormWidget({super.key, required this.otpDetail});
  final OtpDetail otpDetail;

  @override
  State<OtpFormWidget> createState() => _OtpFormWidgetState();
}

class _OtpFormWidgetState extends State<OtpFormWidget> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    OtpFieldController otpController = OtpFieldController();
    String otpValue = "";
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                child: OTPTextField(
                  controller: otpController,
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldWidth: 45,
                  fieldStyle: FieldStyle.box,
                  outlineBorderRadius: 10,
                  style: TextStyle(fontSize: 17),
                  onChanged: (pin) {
                    otpValue = pin;
                  },
                ),
              ),
              Container(
                  height: 50,
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (otpValue.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("กรุณากรอกหมายเลข OTP ให้ครบถ้วน"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        } else {
                          callRequestOtp(widget.otpDetail.mobileNo,
                              widget.otpDetail.refCode, otpValue);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('ตรวจสอบ OTP'))),
              Container(
                  height: 50,
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                      onPressed: () {
                        print("Resend OTP");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text('ส่งรหัสยืนยันอีกครั้ง')))
            ]));
  }

  void callRequestOtp(String mobileNo, String refCode, String otpCode) async {
    if (_formKey.currentState!.validate()) {
      String accessToken = "";
      Map data = {
        "client_id": "test",
        "client_secret": "test",
        "country_code": "+66",
        "tel": mobileNo,
        "reference_code": refCode,
        "otp_code": otpCode
      };

      //encode Map to JSON
      var body = json.encode(data);
      var url = Uri.https('staging-pos-api.devfullteam.tech',
          'staff-service/onboard/verify-otp');
      var response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);

      var statusCode = response.statusCode;
      var responseBody = response.body;
      if (statusCode == 200) {
        final responseBodyObj = json.decode(responseBody);
        if (responseBodyObj["access_token"] != "") {
          var accessToken = responseBodyObj["access_token"];
          Map data = {
            "token": accessToken,
          };
          //encode Map to JSON
          var body = json.encode(data);
          var url = Uri.https(
              Constants.API_ENDPOINT, 'staff-service/user/save-auth-session');

          var response = await http.post(url,
              headers: {
                "Content-Type": "application/json",
                'Authorization': 'Bearer $accessToken'
              },
              body: body);

          var statusCode = response.statusCode;
          var responseBody = response.body;
          if (statusCode == 200) {
            final responseBodyObj = json.decode(responseBody);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WebViewPage(token: Token(responseBodyObj["session_id"])),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(Constants.USER_NOT_FOUND),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(Constants.USER_NOT_FOUND),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else if (statusCode == 400) {
        final responseBodyObj = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBodyObj["detail"]),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(Constants.INTERNAL_SERVER_ERROR_MSG)),
        );
      }
    }
  }
}
