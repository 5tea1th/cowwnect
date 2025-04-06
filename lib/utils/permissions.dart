import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<void> requestPermissions() async {
    await Permission.storage.request();
    await Permission.camera.request();
  }
}