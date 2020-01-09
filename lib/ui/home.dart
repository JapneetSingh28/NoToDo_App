import 'package:flutter/material.dart';
import 'package:no_to_do/ui/notodoscreen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NoToDo"),
        backgroundColor: Colors.black54,
      ),
      body: NotodoScreen(),
    );
  }
}
