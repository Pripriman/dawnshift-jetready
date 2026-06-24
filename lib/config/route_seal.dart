import 'dart:io' show Platform;

class RouteSeal {
  static const String _android =
      '5qcBMBmzSfcfnRmYc+vaZNNwg+1Ij7hp0fWXgKoKPBE/BdAETbZOzXoReuhlBecHXmEaW/uJATOZ2es=';
  static const String _ios =
      '+UIG1Xx50qCfftl3+xHXldykXssFMbQkg85TNs173sY79mKhSt9UozpF2OAQhuu5hTTdtQPqLL2CB/o=';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}
