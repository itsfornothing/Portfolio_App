import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

String formatRelativeDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    final now = DateTime.now().toUtc(); 

    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    }
    else if (difference == 1) {
      return 'yesterday';
    }
    else if (difference <= 7) {
      return '$difference days ago';
    }
    else {
      return DateFormat('MMM d, yyyy').format(date.toLocal());
    }
  } catch (e) {
    print('Error parsing date: $e');
    return 'N/A';
  }
}


String? validateFullName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Full name cannot be empty';
  }
  if (value.length < 2) {
    return 'Full name must be at least 2 characters';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email cannot be empty';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password cannot be empty';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!RegExp(r'\d').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Confirm password cannot be empty';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}

Future<String?> uploadToCloudinary(File file) async {
  const cloudName = "dmao35yzf";
  const uploadPreset = "portfolio_unsigned_preset"; // Create in Cloudinary

  final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");

  var request = http.MultipartRequest("POST", url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', file.path));

  var response = await request.send();
  

  if (response.statusCode == 200) {
    final res = await http.Response.fromStream(response);
    final responseData = jsonDecode(res.body);
    final imageUrl = responseData['secure_url'] as String?;
    return imageUrl;
  } else {
    print("Upload failed: ${response.statusCode}");
    return null;
  }
}
