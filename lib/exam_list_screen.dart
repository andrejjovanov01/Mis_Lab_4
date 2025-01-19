import 'package:flutter/material.dart';

class ExamListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> exams = [
    {
      'name': 'Math Exam',
      'date': DateTime(2025, 1, 20, 10, 0),
      'location': 'Room 101 -TMF',
      'address': 'Ruger Boshkovikj 13'
    },
    {
      'name': 'Physics Exam',
      'date': DateTime(2025, 1, 25, 14, 0),
      'location': 'Room 202 - TMF',
      'address': 'Ruger Boshkovikj 13'
    },
        {
      'name': 'vnp Exam',
      'date': DateTime(2025, 1, 25, 18, 0),
      'location': 'Room 202 - TMF',
      'address': 'Ruger Boshkovikj 13'
    },
    {
      'name': 'Chemistry Exam',
      'date': DateTime(2025, 2, 10, 9, 0),
      'location': 'Room 303 -TMF',
      'address': 'Ruger Boshkovikj 13'
    },
  ];

  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Exams'),
      ),
      body: ListView.builder(
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];
          return Card(
            child: ListTile(
              title: Text(exam['name']),
              subtitle: Text(
                  '${exam['date']} at ${exam['location']}'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.pop(context, {
                    'date': exam['date'],
                    'event': '${exam['name']} at ${exam['location']}',
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
