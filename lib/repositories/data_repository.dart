import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/network/api.dart';
import 'package:spo_balaesang/network/api_service.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class DataRepository {
  DataRepository({@required this.apiService});

  final ApiService apiService;

  Future<List<Employee>> getAllEmployee() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Employee> employee;
    try {
      final Map<String, dynamic> _data =
          await apiService.getEndpointData(endpoint: Endpoint.users);
      final List<dynamic> _result = _data['data'] as List<dynamic>;
      if (prefs.containsKey(prefsEmployeeKey)) {
        prefs.remove(prefsEmployeeKey);
        prefs.reload();
      }
      prefs.setString(prefsEmployeeKey, jsonEncode(_data['data']));
      employee = _result
          .map(
              (dynamic json) => Employee.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      final Map<String, dynamic> data =
          jsonDecode(prefs.getString(prefsEmployeeKey)) as Map<String, dynamic>;
      final List<dynamic> _data = data['data'] as List<dynamic>;
      employee = _data
          .map(
              (dynamic json) => Employee.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {}
    return employee;
  }

  Future<User> getMyData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    User user;
    try {
      final Map<String, dynamic> _data =
          await apiService.getEndpointData(endpoint: Endpoint.my);
      prefs.remove(prefsUserKey);
      prefs.reload();
      prefs.setString(prefsUserKey, jsonEncode(_data['data']));
      user = User.fromJson(_data['data'] as Map<String, dynamic>);
    } on SocketException {
      return null;
    } catch (e) {}
    return user;
  }

  Future<Map<String, dynamic>> logout() async {
    Map<String, dynamic> response;
    try {
      final Map<String, dynamic> _data =
          await apiService.getEndpointData(endpoint: Endpoint.logout);
      response = _data;
    } catch (e) {}
    return response;
  }

  Future<Response> login(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithoutToken(
          endpoint: Endpoint.login, data: data);
    } catch (e) {}
    return response;
  }

  Future<Response> changePass(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.changePass, data: data);
    } catch (e) {}
    return response;
  }

  Future<Map<String, dynamic>> permission(Map<String, dynamic> data) async {
    Map<String, dynamic> result;
    try {
      final response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.permission, data: data);
      result = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {}
    return result;
  }

  Future<Map<String, dynamic>> getAllPermissions(DateTime date) async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(
          endpoint: Endpoint.permission, query: {'date': date.toString()});
    } catch (e) {}
    return data;
  }

  Future<Map<String, dynamic>> getAllEmployeePermissions(DateTime date) async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(
          endpoint: Endpoint.employeePermission,
          query: {'date': date.toString()});
    } catch (e) {}
    return data;
  }

  Future<Response> approvePermission(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.approvePermission, data: data);
    } catch (e) {}
    return response;
  }

  Future<Map<String, dynamic>> changePermissionPhoto(
      Map<String, dynamic> data) async {
    Map<String, dynamic> result;
    try {
      final response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.changePermissionPhoto, data: data);
      result = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {}
    return result;
  }

  Future<Map<String, dynamic>> outstation(Map<String, dynamic> data) async {
    Map<String, dynamic> result;
    try {
      final response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.outstation, data: data);
      result = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {}
    return result;
  }

  Future<Map<String, dynamic>> getAllOutstation(DateTime date) async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(
          endpoint: Endpoint.outstation, query: {'date': date.toString()});
    } catch (e) {}
    return data;
  }

  Future<Map<String, dynamic>> getAllEmployeeOutstation(DateTime date) async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(
          endpoint: Endpoint.employeeOutstation,
          query: {'date': date.toString()});
    } catch (e) {}
    return data;
  }

  Future<Response> approveOutstation(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.approveOutstation, data: data);
    } catch (e) {}
    return response;
  }

  Future<Map<String, dynamic>> changeOutstationPhoto(
      Map<String, dynamic> data) async {
    Map<String, dynamic> result;
    try {
      final response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.changeOutstationPhoto, data: data);
      result = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {}
    return result;
  }

  Future<Map<String, dynamic>> getAllNotifications() async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(endpoint: Endpoint.notifications);
    } catch (e) {}
    return data;
  }

  Future<Map<String, dynamic>> getStatistics(DateTime date,
      [int userId]) async {
    Map<String, dynamic> data;

    final Map<String, String> queries = {
      'year': date.year.toString(),
      'month': date.month.toString(),
    };

    if (userId != null) {
      queries['user_id'] = userId.toString();
    }

    try {
      data = await apiService.getEndpointData(
          endpoint: Endpoint.statistics, query: queries);
    } catch (e) {}
    return data;
  }

  Future<Response> readNotification(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.notifications, data: data);
    } catch (e) {}
    return response;
  }

  Future<Map<String, dynamic>> readAllNotifications() async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(
          endpoint: Endpoint.readNotifications);
    } catch (e) {}
    return data;
  }

  Future<Map<String, dynamic>> deleteAllNotifications() async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(
          endpoint: Endpoint.deleteNotifications);
    } catch (e) {}
    return data;
  }

  Future<Map<String, dynamic>> sendNotification(
      Map<String, dynamic> data) async {
    Map<String, dynamic> result;
    try {
      final response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.sendNotifications, data: data);
      result = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {}
    return result;
  }

  Future<Response> presence(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.presence, data: data);
    } catch (e) {}
    return response;
  }

  Future<Map<String, dynamic>> getAllPaidLeave(DateTime date) async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(
          endpoint: Endpoint.paidLeave, query: {'date': date.toString()});
    } catch (e) {}
    return data;
  }

  Future<Map<String, dynamic>> getAllEmployeePaidLeave(DateTime date) async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(
          endpoint: Endpoint.employeePaidLeave,
          query: {'date': date.toString()});
    } catch (e) {}
    return data;
  }

  Future<Map<String, dynamic>> changePaidLeavePhoto(
      Map<String, dynamic> data) async {
    Map<String, dynamic> result;
    try {
      final response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.changePaidLeavePhoto, data: data);
      result = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {}
    return result;
  }

  Future<Response> approvePaidLeave(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.approvePaidLeave, data: data);
    } catch (e) {}
    return response;
  }

  Future<Map<String, dynamic>> paidLeave(Map<String, dynamic> data) async {
    Map<String, dynamic> result;
    try {
      final response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.paidLeave, data: data);
      result = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {}
    return result;
  }

  Future<Response> cancelAttendance(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.cancelAttendance, data: data);
    } catch (e) {}
    return response;
  }
}
