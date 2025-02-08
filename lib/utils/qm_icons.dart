import 'package:flutter/material.dart';

IconData _generate(int num) {
  return IconData(
    num,
    fontFamily: 'QmIcon',
    matchTextDirection: true,
  );
}

class QmIcons {
  static IconData close = _generate(0xe6e9);

  /// 粗体
  static IconData close2 = _generate(0xe63c);

  static IconData success = _generate(0xe678);

  static IconData back = _generate(0xe64e);

  static IconData right = _generate(0xe634);

  static IconData up = _generate(0xe610);

  static IconData down = _generate(0xe688);

  static IconData recycle = _generate(0xe647);

  static IconData search = _generate(0xe623);

  static IconData write = _generate(0xe646);

  static IconData calendar = _generate(0xe61d);

  static IconData setting = _generate(0xe642);

  static IconData user = _generate(0xe716);

  static IconData defense = _generate(0xe632);

  static IconData book = _generate(0xe7e9);

  static IconData empty = _generate(0xe6a6);

  static IconData homeFill = _generate(0xe660);

  static IconData mineFill = _generate(0xe65b);

  static IconData workFill = _generate(0xe68c);
}
