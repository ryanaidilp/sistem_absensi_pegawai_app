enum Endpoint { login, logout, change_pass, users, presence, my, permission,
employeePermission, approvePermission}

class API {
  final String host = 'http://192.168.43.76:8000';

  String endpointUri(Endpoint endpoint) => '$host/api/${_paths[endpoint]}';

  static Map<Endpoint, String> _paths = {
    Endpoint.login: 'login',
    Endpoint.logout: 'logout',
    Endpoint.change_pass: 'change_password',
    Endpoint.users: 'user',
    Endpoint.presence: 'presence',
    Endpoint.permission: 'permission',
    Endpoint.my: 'my',
    Endpoint.employeePermission : 'permission/all',
    Endpoint.approvePermission : 'permission/approve'
  };
}
