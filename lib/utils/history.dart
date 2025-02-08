import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get.dart';
import 'global_context.dart';
import 'dart:async';

typedef HistoryState = ({String action, Object? data});

typedef HistoryLocation = ({String action, String routeName});

class History {
  static String _action = '';
  static String _routeName = '';

  static get action => _action;

  static get routeName => _routeName;

  static get state => (ModalRoute.of(GlobalVars.context!)!.settings.arguments as HistoryState).data;

  static Future<T?> push<T>(String routeName, {Object? state}) async {
    _action = 'PUSH';
    _routeName = routeName;
    HistoryState arguments = (action: 'PUSH', data: state);
    dynamic result =
        await Navigator.of(GlobalVars.context!).pushNamed(routeName, arguments: arguments);

    return result as T;
  }

  static Future replace<T>(String routeName, {Object? state}) async {
    _action = 'REPLACE';
    _routeName = routeName;
    HistoryState arguments = (action: 'REPLACE', data: state);
    await Navigator.of(GlobalVars.context!).pushReplacementNamed(
      routeName,
      result: {'sxx': 'ssssssss'},
      arguments: arguments,
    );
  }

  static pop<T>([T? result]) {
    _action = 'POP';

    /// 更新全局的 context
    Navigator.of(GlobalVars.context!).pop(result);
  }

  static popUntil(String routeName) {
    _action = 'POP';
    _routeName = routeName;

    /// 更新全局的 context
    Navigator.of(GlobalVars.context!).popUntil((Route route) => route.settings.name == routeName);
  }
}
