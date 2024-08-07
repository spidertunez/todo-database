import 'package:flutter/material.dart';

import 'b1.dart';



void main() {
  runApp( MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( debugShowCheckedModeBanner: false,
 home: b1(),
       initialRoute: '/b1',
      routes: {
        '/b1':(context) => b1(),


      }
      ,
    );
  }
}
