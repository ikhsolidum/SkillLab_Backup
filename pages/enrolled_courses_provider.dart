import 'package:flutter/material.dart';
import 'course.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EnrolledCoursesProvider extends ChangeNotifier {
  List<Course> _enrolledCourses = [];
  List<Course> get enrolledCourses => _enrolledCourses;

  void addCourse(String courseName, String email) {
    _enrolledCourses.add(Course(courseName, email));
    notifyListeners();
  }

  void updateCourses(List<dynamic> coursesData) {
    _enrolledCourses = coursesData.map((course) => Course(course['name'], course['email'])).toList();
    notifyListeners();
  }

 void deleteCourse(String courseName) async {
  final url = Uri.parse('https://ikhsolidum.helioho.st/courseconnect.php');

  try {
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': courseName}), 
    );

    if (response.statusCode == 200) {
      _enrolledCourses.removeWhere((course) => course.name == courseName);
      notifyListeners();
    } else {
      // Handle error
      print('Failed to delete course: ${response.body}');
    }
  } catch (e) {
    // Handle exception
    print('Exception: $e');
  }
}

  Map<String, dynamic> getCoursesData() {
    return {
      'email': 'example@email.com', // Replace with the actual email
      'courses': _enrolledCourses.map((course) => {
        'name': course.name,
        'email': course.email,
      }).toList(),
    };
  }
}
