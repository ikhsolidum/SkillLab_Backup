import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skilllab/pages/enrolled_courses_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Add this import for jsonEncode

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EnrolledCoursesProvider(),
      child: MaterialApp(
        title: 'My App',
        home: EnrolledCoursesPage(email: 'example@email.com'),
      ),
    );
  }
}

class EnrolledCoursesPage extends StatefulWidget {
  final String email;

  EnrolledCoursesPage({Key? key, required this.email}) : super(key: key);

  @override
  _EnrolledCoursePageState createState() => _EnrolledCoursePageState();
}

class _EnrolledCoursePageState extends State<EnrolledCoursesPage> {
  late final EnrolledCoursesProvider enrolledCoursesProvider;

  @override
void initState() {
  super.initState();
  enrolledCoursesProvider = context.read<EnrolledCoursesProvider>();
  fetchCoursesData(enrolledCoursesProvider);
}


  void _sendCoursesData() {
    sendCoursesData(enrolledCoursesProvider);
  }

 Future<void> fetchCoursesData(EnrolledCoursesProvider enrolledCoursesProvider) async {
    final url = Uri.parse('https://ikhsolidum.helioho.st/courseconnect.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final coursesData = jsonDecode(response.body);
        enrolledCoursesProvider.updateCourses(coursesData);
      } else {
        print('Failed to fetch courses data from server: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

@override
Widget build(BuildContext context) {
  final enrolledCoursesProvider = Provider.of<EnrolledCoursesProvider>(context);

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Enrolled Courses',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: const Color.fromARGB(255, 3, 3, 3)),
    ),
    backgroundColor: Colors.grey[100],
    body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enrolled Course/s',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: enrolledCoursesProvider.enrolledCourses.length,
                      itemBuilder: (context, index) {
                        final course = enrolledCoursesProvider.enrolledCourses[index];
                        return ListTile(
                          title: Text(
                            course.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, color: Colors.black87),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                enrolledCoursesProvider.deleteCourse(course.name);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _sendCoursesData,
                      child: Text('Save Courses'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              'Back',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}



Future<void> sendCoursesData(EnrolledCoursesProvider enrolledCoursesProvider) async {
  final url = Uri.parse('https://ikhsolidum.helioho.st/courseslist.php');
  final coursesData = enrolledCoursesProvider.getCoursesData();
  final body = _encodeRequestBody(coursesData);

  try {
    final response = await http.post(
      url,
      body: body,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Courses data sent to server successfully.');
    } else {
      print('Failed to send courses data to server. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception occurred while sending courses data: $e');
  }
}



String _encodeRequestBody(Map<String, dynamic> data) {
  final emailKey = 'email';
  final coursesKey = 'courses';

  final buffer = StringBuffer();
  buffer.write('{');

  buffer.write('"$emailKey":"${data[emailKey]}",');
  buffer.write('"$coursesKey":[');

  for (var i = 0; i < data[coursesKey].length; i++) {
    final course = data[coursesKey][i];
    buffer.write('{');
    course.forEach((key, value) {
      buffer.write('"$key":"$value"');
      if (key != course.keys.last) buffer.write(',');
    });
    buffer.write('}');
    if (i < data[coursesKey].length - 1) buffer.write(',');
  }

  buffer.write(']}');

  return buffer.toString();
}
}
