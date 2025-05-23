// lib/features/auth/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogicService {
  //'http://103.59.160.119:3240/api'; // Define your base URL

  // This is your postData function, now as a method of AuthService
  Future<Map<String, dynamic>?> lUser(String username, String password) async {
    // Renamed for clarity
    final url = Uri.parse('http://103.59.160.119:3240/api/');
    final Map<String, String> body = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Login successful: ${response.body}');
        return json.decode(response.body)
            as Map<String, dynamic>; // Return decoded data
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        // Consider throwing a custom exception or returning a specific error object
        return null;
      }
    } catch (e) {
      print('Error making POST request: $e');
      // Consider throwing a custom exception
      return null;
    }
  }

  // You could add your registerUser API call here too
  Future<Map<String, dynamic>?> registerUser(
    String username,
    String email,
    String password,
    String role,
  ) async {
    final url = Uri.parse('http://103.59.160.119:3240/api/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Registration failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in AuthService.register: $e');
      return null;
    }
  }
}
