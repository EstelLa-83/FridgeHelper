import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermissionIfNeeded() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    final result = await Permission.notification.request();
    print('🔔 일반 알림 권한 요청 결과: $result');
  }
}