library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _decoder = JsonDecoder();
const _encoder = JsonEncoder();

class Storage {
  static SharedPreferences? _storage;

  static Future<T?> getItem<T>(String key) async {
    try {
      _storage ??= await SharedPreferences.getInstance();
      String? value = _storage!.getString(key);
      return value == null ? null : _decoder.convert(value) as T;
    } catch (err) {
      return null;
    }
  }

  static Future<bool> setItem(String key, dynamic value) async {
    try {
      _storage ??= await SharedPreferences.getInstance();
      String json = _encoder.convert(value);
      await _storage!.setString(key, json);
      return true;
    } catch (err) {
      return false;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      _storage ??= await SharedPreferences.getInstance();

      await _storage!.remove(key);
      return true;
    } catch (err) {
      return false;
    }
  }
}
