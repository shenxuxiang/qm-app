import 'package:flutter/material.dart';

class TabMine extends StatefulWidget {
  const TabMine({super.key});

  @override
  State<TabMine> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabMine> {
  @override
  void initState() {
    debugPrint('22222');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('个人中心', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
