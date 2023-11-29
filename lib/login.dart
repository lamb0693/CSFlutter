import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _toPrevious() {
    Navigator.pop(context);
    // setState(() {
    //   _counter++;
    // });
  }

  void _login() async{
    String id = _idController.text;
    String password = _passwordController.text;
    if (kDebugMode) {
      print('ID: $id, Password: $password');
    }

    // var res = await http.get(Uri.parse('http://192.168.200.197:8080'));
    // if (kDebugMode) {
    //   print(jsonDecode(res.body));
    // }

    Map<String, String> requestBody = {
      'tel': id,
      'password': password,
    };

    var response = await http.post(Uri.parse('http://192.168.200.197:8080/getToken'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (kDebugMode) {
      print('Response status: ${response.statusCode}');
    }
    if (kDebugMode) {
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home : Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'ID',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children:[
                const Icon(Icons.access_time_filled),
                const Icon(Icons.star),
                ElevatedButton(
                  onPressed: _toPrevious,
                  child: const Text('돌아가기')
                ),
              ],
            ),
          ),
        )
    );
  }
}