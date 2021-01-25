import 'package:flutter_config/flutter_config.dart';

enum Endpoint {
  login,
  logout,
  change_pass,
  users,
  presence,
  my,
  permission,
  employeePermission,
  approvePermission,
  outstation,
  employeeOutstation,
  approveOutstation,
  notifications,
  readNotifications,
  deleteNotifications,
  sendNotifications,
  statistics,
  paidLeave,
  employeePaidLeave,
  approvePaidLeave,
  cancelAttendance,
  changePermissionPhoto,
  changeOutstationPhoto,
  changePaidLeavePhoto,
}

class API {
  final String host = FlutterConfig.get("BASE_URL");

  String endpointUri(Endpoint endpoint) => '$host/api/${_paths[endpoint]}';

  static Map<Endpoint, String> _paths = {
    Endpoint.login: 'login',
    Endpoint.logout: 'logout',
    Endpoint.change_pass: 'change_password',
    Endpoint.users: 'user',
    Endpoint.presence: 'presence',
    Endpoint.my: 'my',
    Endpoint.permission: 'permission',
    Endpoint.employeePermission: 'permission/all',
    Endpoint.approvePermission: 'permission/approve',
    Endpoint.outstation: 'outstation',
    Endpoint.employeeOutstation: 'outstation/all',
    Endpoint.approveOutstation: 'outstation/approve',
    Endpoint.notifications: 'notifications',
    Endpoint.readNotifications: 'notifications/read',
    Endpoint.deleteNotifications: 'notifications/delete',
    Endpoint.sendNotifications: 'notifications/send',
    Endpoint.statistics: 'statistics',
    Endpoint.paidLeave: 'paid-leave',
    Endpoint.employeePaidLeave: 'paid-leave/all',
    Endpoint.approvePaidLeave: 'paid-leave/approve',
    Endpoint.cancelAttendance: 'presence/cancel',
    Endpoint.changePermissionPhoto: 'permission/picture',
    Endpoint.changeOutstationPhoto: 'outstation/picture',
    Endpoint.changePaidLeavePhoto: 'paid-leave/picture',
  };
}
