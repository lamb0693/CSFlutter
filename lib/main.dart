import 'package:flutter/material.dart';
import 'package:flutter_hello/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CS Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  // void _incrementCounter() {
  //   setState(() {
  //     _counter++;
  //   });
  // }
  void _moveToLogin() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const LoginPage(title: "Login")));
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
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 50,
                color: Colors.amber[colorCodes[index]],
                child: Center(child: Text('Entry ${entries[index]}')),
              );
            },
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children:[
              const Icon(Icons.access_time_filled),
              const Icon(Icons.star),
              ElevatedButton(
                onPressed: _moveToLogin,
                child: const Text('Login')
              ),
            ],
          ),
        ),
      )
    );
  }
}
