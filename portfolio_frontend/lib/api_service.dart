import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080/api/';
  static const storage = FlutterSecureStorage();

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']['token'];
      await storage.write(key: 'auth_token', value: token);
      return token;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> signup(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Signup failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.post(
      Uri.parse('${baseUrl}logout/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await storage.delete(key: 'auth_token');
    } else {
      throw Exception('Logout failed: ${response.body}');
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> fetchHomePage() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('${baseUrl}home/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to fetch home page: ${response.body}');
    }
  }

  Future<void> aboutMeUpdate(String aboutMe) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.patch(
      Uri.parse('${baseUrl}admin-profile/update/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'about_me': aboutMe}),
    );
    if (response.statusCode != 200) {
      throw Exception('About me update failed: ${response.body}');
    }
  }

  Future<void> profileUpdate(String career, String city, String country) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.patch(
      Uri.parse('${baseUrl}admin-profile/update/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'career': career, "country": country, 'city': city}),
    );
    if (response.statusCode != 200) {
      throw Exception('Profile update failed: ${response.body}');
    }
  }

  Future<void> skillsUpdate(List<String> skills) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    for (var skill in skills) {
      final response = await http.post(
        Uri.parse('${baseUrl}skills/add/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': skill}),
      );
      if (response.statusCode != 201) {
        throw Exception('Skill update failed: ${response.body}');
      }
    }
  }

  Future<void> createProject(
    String title,
    String description,
    String imgUrl,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.post(
      Uri.parse('${baseUrl}project/add/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'image': imgUrl,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Project creation failed: ${response.body}');
    }
  }

  Future<void> deleteProject(int projectId) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.delete(
      Uri.parse('${baseUrl}project/delete/$projectId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete project: ${response.body}');
    }
  }

  Future<void> createBlog(
    String title,
    String content,
    String category,
    String imgUrl,
  ) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${baseUrl}blog/add/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'title': title,
        'content': content,
        'category': category,
        'image': imgUrl,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Project creation failed: ${response.body}');
    }
  }

  Future<void> deleteBlog(String title) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    print(
      'Sending DELETE request to ${baseUrl}blog/delete/$title/ with token: $token',
    );
    final response = await http.delete(
      Uri.parse('${baseUrl}blog/delete/$title/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('Response status: ${response.statusCode}, body: ${response.body}');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete blog: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchBlogs() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('${baseUrl}blogs/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results']['data'] == null) {
        return [];
      }
      print(data);
      return data['results']['data'];
    } else {
      throw Exception('Failed to fetch projects: ${response.body}');
    }
  }

  Future<void> addBlogComment(String title, String comment) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.post(
      Uri.parse('${baseUrl}blog/comments/$title/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': comment}),
    );
    if (response.statusCode != 201) {
      throw Exception('Comment creation failed: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchBlogComments(String title) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('${baseUrl}blog/comments/$title/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results']['data'] == null) {
        return [];
      }
      return data['results']['data'];
    } else {
      throw Exception('Failed to fetch comments: ${response.body}');
    }
  }

  Future<void> addProjectComment(String title, String comment) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.post(
      Uri.parse('${baseUrl}project/comments/$title/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': comment}),
    );
    if (response.statusCode != 201) {
      throw Exception('Comment creation failed: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchProjectComments(String title) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('${baseUrl}project/comments/$title/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results']['data'] == null) {
        return [];
      }
      return data['results']['data'];
    } else {
      throw Exception('Failed to fetch comments: ${response.body}');
    }
  }

  Future<void> userProfileUpdate(String profileUrl) async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.patch(
      Uri.parse('${baseUrl}user-profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'profile_url': profileUrl}),
    );
    if (response.statusCode != 200) {
      throw Exception('Profile Image update failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> userProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('${baseUrl}user-profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to fetch profile data: ${response.body}');
    }
  }
}
