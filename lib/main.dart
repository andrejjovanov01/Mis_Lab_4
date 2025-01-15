import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'exam_list_screen.dart';

void main() {
  runApp(ExamScheduleApp());
}

class ExamScheduleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Schedule',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Map to hold selected events
  final Map<DateTime, List<String>> _events = {};

  // Function to add events
  void _addEvent(DateTime date, String event) {
    setState(() {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (_events[normalizedDate] == null) {
        _events[normalizedDate] = [];
      }
      _events[normalizedDate]!.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Schedule'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamListScreen(),
                ),
              );

              // If an event was added, update the calendar
              if (result != null && result is Map<String, dynamic>) {
                _addEvent(result['date'], result['event']);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              final normalizedDate = DateTime(day.year, day.month, day.day);
              return _events[normalizedDate] ?? [];
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView(
              children: (_events[DateTime(_selectedDay?.year ?? 0,
                      _selectedDay?.month ?? 0, _selectedDay?.day ?? 0)] ??
                  [])
                  .map((event) => ListTile(
                        title: Text(event),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
