import 'dart:io' show Platform;

class RouteSeal {
  static const String _android =
      'UnlwtLJDdl1H6pSUxUO-yHlEXgV_1bRdrDIIeGoh7yFd945fYcCaTS9I4bbroDmE1vhBlC-eHuXRYA';
  static const String _ios =
      '6sFt8EIbG5yPc29OnAaMUyDq7xQPUwtP9dMD95ntbyHI4WX-ugnYRPZUUSHqLe3bXrieVwOAH6QC5A';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}
