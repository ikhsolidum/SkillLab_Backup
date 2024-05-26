import 'package:flutter/material.dart';
import 'course.dart';

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

 void deleteCourse(String courseName) {
    _enrolledCourses.removeWhere((course) => course.name == courseName);
    notifyListeners();
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
