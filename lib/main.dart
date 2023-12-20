// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Manager'),
      ),
      body: Center(
        child: LoginUsernamePage(),
      ),
    );
  }
}

class LoginUsernamePage extends StatefulWidget {
  const LoginUsernamePage({super.key});

  @override
  State<LoginUsernamePage> createState() => _LoginUsernamePageState();
}

class _LoginUsernamePageState extends State<LoginUsernamePage> {
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
                  'CM Tool Managemant',
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
                  'หรือ',
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
                  child: const Text('ลงชื่อเข้าใช้ด้วย OTP'),
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
                child: const Text('ลงชื่อเข้าใช้'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Processing Data')),
                    // );

                    Map data = {
                      "client_id": "test",
                      "client_secret": "test",
                      "grant_type": "password",
                      "password": passwordController.text,
                      "username": nameController.text
                    };
                    //encode Map to JSON
                    var body = json.encode(data);
                    var url = Uri.https('staging-pos-api.devfullteam.tech',
                        'staff-service/OAuth/token');
                    var response = await http.post(url,
                        headers: {"Content-Type": "application/json"},
                        body: body);

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
                        var url = Uri.https('staging-pos-api.devfullteam.tech',
                            'staff-service/user/save-auth-session');

                        var response = await http.post(url,
                            headers: {
                              "Content-Type": "application/json",
                              'Authorization': "Bearer " + accessToken
                            },
                            body: body);

                        var statusCode = response.statusCode;
                        var responseBody = response.body;
                        if (statusCode == 200) {
                          final responseBodyObj = json.decode(responseBody);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebViewPage(
                                  token: Token(responseBodyObj["session_id"])),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Incorrect username or password')),
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
                              content: Text('Incorrect username or password')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Incorrect username or password')),
                      );
                    }
                  }
                },
              )),
        ],
      ),
    );
    ;
  }
}

class WebViewPage extends StatelessWidget {
  const WebViewPage({super.key, required this.token});

  final Token token;

  @override
  Widget build(BuildContext context) {
    WebViewController? _controller;
    return Scaffold(
      appBar: AppBar(
        title: const Text("CM Tool Management"),
        automaticallyImplyLeading: false,
      ),
      body: WebView(
        zoomEnabled: false,
        initialUrl:
            "https://staging-eazypos-cms.devfullteam.tech/session-auth?session_id=" +
                token.accessToken,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
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
        //  body: Center(child: LoginMobileNoFormWidget()));
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'CM Tool Managemant',
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
                    'หรือ',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกหมายเลขโทรศัพท์';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'หมายเลขโทรศัพท์',
                ),
              )),
          Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                    }
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
}
