import 'package:flutter/material.dart';

class TabWork extends StatefulWidget {
  const TabWork({super.key});

  @override
  State<TabWork> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabWork> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('作业信息', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
