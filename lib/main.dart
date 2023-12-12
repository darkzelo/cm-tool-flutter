import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MaterialApp(
    title: 'CM Tools Demo',
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
          ),
          body: Center(
            child: Padding(
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
                        child: const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 20),
                        )),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'User Name',
                        ),
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
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Can\'t be empty';
                          }
                          if (text.length < 4) {
                            return 'Too short';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                        height: 50,
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          child: const Text('Login'),
                          onPressed: () async {
                            Map data = {
                              "client_id": "test",
                              "client_secret": "test",
                              "grant_type": "password",
                              "password": passwordController.text,
                              "username": nameController.text
                            };
                            //encode Map to JSON
                            var body = json.encode(data);
                            var url = Uri.https(
                                'staging-pos-api.devfullteam.tech',
                                'staff-service/OAuth/token');
                            var response = await http.post(url,
                                headers: {"Content-Type": "application/json"},
                                body: body);

                            var statusCode = response.statusCode;
                            var responseBody = response.body;

                            if (statusCode == 200) {
                              final responseBodyObj = json.decode(responseBody);
                              if (responseBodyObj["access_token"] != "") {
                                var accessToken =
                                    responseBodyObj["access_token"];
                                Map data = {
                                  "token": accessToken,
                                };
                                //encode Map to JSON
                                var body = json.encode(data);
                                var url = Uri.https(
                                    'staging-pos-api.devfullteam.tech',
                                    'staff-service/user/save-auth-session');

                                var response = await http.post(url,
                                    headers: {
                                      "Content-Type": "application/json",
                                      'Authorization': "Bearer " + accessToken
                                    },
                                    body: body);

                                var statusCode = response.statusCode;
                                var responseBody = response.body;
                                print("save-auth-session: " + responseBody);
                                if (statusCode == 200) {
                                  final responseBodyObj =
                                      json.decode(responseBody);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SecondRoute(
                                          token: Token(
                                              responseBodyObj["session_id"])),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Incorrect username or password')),
                                  );
                                }

                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => SecondRoute(
                                //         token: Token(
                                //             responseBodyObj["access_token"])),
                                //   ),
                                // );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Incorrect username or password')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Incorrect username or password')),
                              );
                            }
                          },
                        )),
                  ],
                )),
          ),
        ));
  }
}

class Token {
  final String accessToken;
  const Token(this.accessToken);
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key, required this.token});

  final Token token;

  @override
  Widget build(BuildContext context) {
    WebViewController? _controller;
    print("SecondRoute: " + token.accessToken);
    return Scaffold(
        appBar: AppBar(
          title: Text("CM Tool Management"),
        ),
        body: WebView(
          zoomEnabled: false,
          initialUrl: "https://staging-eazypos-cms.devfullteam.tech/",
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
          },
        ));
  }
}
