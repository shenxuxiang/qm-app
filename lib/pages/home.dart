import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qm/common/base_page.dart';
import 'package:qm/utils/index.dart' as utils;
import 'package:qm/pages/tab_home/index.dart';
import 'package:qm/pages/tab_work/index.dart';
import 'package:qm/pages/tab_mine/index.dart';
import 'package:qm/components/keep_alive.dart';

class HomePage extends BasePage {
  const HomePage({super.key, super.title});

  @override
  BasePageState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BasePageState<HomePage> {
  late final PageController _controller;
  int _activeKey = 0;

  @override
  void initState() {
    _controller = PageController(initialPage: _activeKey);
    super.initState();
  }

  void handleChangeActiveKey(int value) {
    setState(() {
      _activeKey = value;
    });

    _controller.jumpToPage(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: [
          KeepAliveWidget(
            keepAlive: true,
            child: const TabHome(),
          ),
          KeepAliveWidget(
            keepAlive: true,
            child: const TabWork(),
          ),
          KeepAliveWidget(
            keepAlive: true,
            child: const TabMine(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeKey,
        onTap: handleChangeActiveKey,
        backgroundColor: Color(0xFFF9F9F9),
        selectedItemColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            label: '首页',
            icon: Icon(utils.QmIcons.homeFill),
          ),
          BottomNavigationBarItem(
            label: '作业',
            icon: Icon(utils.QmIcons.workFill),
          ),
          BottomNavigationBarItem(
            label: '我的',
            icon: Icon(utils.QmIcons.mineFill),
          ),
        ],
      ),
    );
  }
}
