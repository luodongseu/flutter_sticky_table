import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sticky_table/flutter_sticky_table.dart';

void main() {
//  debugProfileBuildsEnabled = true;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sticky Table Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter sticky table Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  List<ColumnsProps> columns = [];
  List<dynamic> data = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    columns = [
      ColumnsProps('c1', 'k1',
          customTitle: RaisedButton(
              onPressed: () {
                _counter++;
                setState(() {});
              },
              child: Text('btn1'))),
      ColumnsProps('c2', 'k2',
          width: 120.0,
          customTitle: RaisedButton(
              onPressed: () {
                _counter++;
                setState(() {});
              },
              child: Text('btn2')), render: (BuildContext c, dynamic value) {
        return Text(
          'custom render: ${value["k2"]}',
        );
      }),
      ColumnsProps('c3', 'k3',
          width: 500.0,
          customTitle: RaisedButton(
              onPressed: () {
                // This call to setState tells the Flutter framework that something has
                // changed in this State, which causes it to rerun the build method below
                // so that the display can reflect the updated values. If we changed
                // _counter without calling setState(), then the build method would not be
                // called again, and so nothing would appear to happen.
                _counter++;
                setState(() {});
              },
              child: Text('btn3'))),
      ColumnsProps('c4', 'k4'),
    ];

    Future.delayed(Duration(seconds: 1), () {
      data = [
        {"k1": "data01", "k2": "data02", "k3": "data03", "k4": "data04"},
        {"k1": "data11", "k2": "data12", "k3": "data13", "k4": "data14"},
        {"k1": "data21", "k2": "data22", "k3": "data23", "k4": "data24"},
        {"k1": "data31", "k2": "data322", "k3": "data33", "k4": "data34"}
      ];
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            SizedBox(
              height: 50,
              child: Container(
                width: double.infinity,
                color: Colors.red.withOpacity(0.1),
                child: Text('Blank Screen Before'),
              ),
            ),
            Text('Table demo:'),
            StickyTable(
              columns: columns,
              data: data,
              stickyColumnCount: 1,
              showBorder: false,
            ),
            SizedBox(
              height: 1500,
              child: Container(
                width: double.infinity,
                color: Colors.red.withOpacity(0.1),
                child: Text('Blank Screen After'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
