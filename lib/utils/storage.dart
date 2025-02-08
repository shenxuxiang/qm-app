library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static final Map<String, Storage> _cache = {};
  final _decoder = JsonDecoder();
  final _encoder = JsonEncoder();
  SharedPreferences? _storage;

  Storage._();

  factory Storage() {
    return _cache.putIfAbsent('storage', () => Storage._());
  }

  init() async {
    _storage ??= await SharedPreferences.getInstance();
  }

  T? getItem<T>(String key) {
    assert(_storage != null);
    String? value = _storage!.getString(key);
    return value == null ? null : _decoder.convert(value) as T;
  }

  Future<bool> setItem(String key, dynamic value) async {
    assert(_storage != null);
    try {
      String json = _encoder.convert(value);
      await _storage!.setString(key, json);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> remove(String key) async {
    assert(_storage != null);
    try {
      await _storage!.remove(key);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> clear() async {
    assert(_storage != null);
    try {
      return _storage!.clear();
    } catch (err) {
      return false;
    }
  }
}

final storage = Storage();
