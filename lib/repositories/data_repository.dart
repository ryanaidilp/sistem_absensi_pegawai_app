import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:spo_balaesang/models/employee.dart';
import 'package:spo_balaesang/models/user.dart';
import 'package:spo_balaesang/network/api.dart';
import 'package:spo_balaesang/network/api_service.dart';

class DataRepository {
  DataRepository({@required this.apiService});

  final ApiService apiService;

  Future<List<Employee>> getAllEmployee() async {
    List<Employee> employee;
    try {
      final Map<String, dynamic> _data =
          await apiService.getEndpointData(endpoint: Endpoint.users);
      final List<dynamic> _result = _data['data'];
      employee =
          _result.map((dynamic json) => Employee.fromJson(json)).toList();
    } catch (e) {
      print(e.toString());
    }
    return employee;
  }

  Future<User> getMyData() async {
    User user;
    try {
      final Map<String, dynamic> _data =
          await apiService.getEndpointData(endpoint: Endpoint.my);
      user = User.fromJson(_data['data']);
    } catch (e) {
      print(e.toString());
    }
    return user;
  }

  Future<Map<String, dynamic>> logout() async {
    Map<String, dynamic> response;
    try {
      final Map<String, dynamic> _data =
          await apiService.getEndpointData(endpoint: Endpoint.logout);
      response = _data;
    } catch (e) {
      print(e.toString());
    }
    return response;
  }

  Future<Response> login(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithoutToken(
          endpoint: Endpoint.login, data: data);
    } catch (e) {
      debugPrint(e.toString());
    }
    return response;
  }

  Future<Response> changePass(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.change_pass, data: data);
    } catch (e) {
      print(e.toString());
    }
    return response;
  }

  Future<Map<String, dynamic>> permission(Map<String, dynamic> data) async {
    Map<String, dynamic> result;
    try {
      var response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.permission, data: data);
      result = jsonDecode(response.body);
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<Map<String, dynamic>> getAllPermissions() async {
    Map<String, dynamic> data;
    try {
      data = await apiService.getEndpointData(endpoint: Endpoint.permission);
    } catch (e) {
      print(e.toString());
    }
    return data;
  }

  Future<Response> presence(Map<String, dynamic> data) async {
    Response response;
    try {
      response = await apiService.postEndpointWithToken(
          endpoint: Endpoint.presence, data: data);
    } catch (e) {
      debugPrint(e.toString());
    }
    return response;
  }
}
