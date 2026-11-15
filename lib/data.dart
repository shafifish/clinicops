/// Fake in-memory data for the prototype. No backend, nothing is persisted.
library;

class Activity {
  Activity({
    required this.time,
    required this.type,
    required this.description,
    required this.author,
    this.pendingSync = false,
  });

  final String time;
  final String type;
  final String description;
  final String author;
  final bool pendingSync;
}

class CountLine {
  CountLine({required this.medicine, required this.expected, this.counted});

  final String medicine;
  final int expected;
  int? counted;

  int? get difference => counted == null ? null : counted! - expected;
}

class CountSession {
  CountSession({
    required this.date,
    required this.counter,
    required this.lines,
  });

  final String date;
  final String counter;
  final List<CountLine> lines;

  int get itemsCounted => lines.where((l) => l.counted != null).length;

  int get discrepancies =>
      lines.where((l) => l.difference != null && l.difference != 0).length;
}

class Task {
  Task({
    required this.title,
    required this.assignee,
    required this.due,
    required this.priority,
    this.status = 'Pending',
  });

  final String title;
  final String assignee;
  final DateTime due;
  final String priority;
  String status;

  bool get isOverdue =>
      status != 'Done' && due.isBefore(DateTime(2026, 11, 14));
}

class SavedReport {
  SavedReport({
    required this.title,
    required this.date,
    required this.approvedBy,
    required this.body,
  });

  final String title;
  final String date;
  final String approvedBy;
  final String body;
}

/// Single shared store. Screens read and mutate these lists directly.
class AppData {
  const AppData._();

  static const String currentUser = 'Siti';
  static const List<String> staff = ['Siti', 'Aminah', 'Hafiz'];

  static final List<Activity> activities = [
    Activity(
      time: '09:15',
      type: 'Delivery',
      description: 'Received medicine delivery, 3 boxes checked in.',
      author: 'Siti',
    ),
    Activity(
      time: '11:40',
      type: 'Maintenance',
      description: 'Fridge temperature checked and recorded.',
      author: 'Aminah',
    ),
    Activity(
      time: '13:05',
      type: 'Note',
      description: 'Saved offline, uploads when back online.',
      author: 'Siti',
      pendingSync: true,
    ),
  ];

  static final CountSession currentSession = CountSession(
    date: '14 Nov 2026',
    counter: 'Siti',
    lines: [
      CountLine(medicine: 'Paracetamol 500mg', expected: 50, counted: 48),
      CountLine(medicine: 'Amoxicillin 250mg', expected: 30, counted: 30),
      CountLine(medicine: 'Loratadine 10mg', expected: 20, counted: 22),
      CountLine(medicine: 'ORS sachet', expected: 75),
      CountLine(medicine: 'Ibuprofen 200mg', expected: 40),
    ],
  );

  static final List<CountSession> pastSessions = [
    CountSession(
      date: '13 Nov 2026',
      counter: 'Siti',
      lines: [
        CountLine(medicine: 'Paracetamol 500mg', expected: 50, counted: 49),
        CountLine(medicine: 'Amoxicillin 250mg', expected: 30, counted: 30),
        CountLine(medicine: 'Loratadine 10mg', expected: 20, counted: 18),
      ],
    ),
    CountSession(
      date: '06 Nov 2026',
      counter: 'Aminah',
      lines: [
        CountLine(medicine: 'Paracetamol 500mg', expected: 50, counted: 50),
        CountLine(medicine: 'ORS sachet', expected: 75, counted: 75),
      ],
    ),
    CountSession(
      date: '30 Oct 2026',
      counter: 'Siti',
      lines: [
        CountLine(medicine: 'Ibuprofen 200mg', expected: 40, counted: 37),
        CountLine(medicine: 'Loratadine 10mg', expected: 20, counted: 20),
      ],
    ),
  ];

  static final List<Task> tasks = [
    Task(
      title: 'Recount ORS sachets',
      assignee: 'Siti',
      due: DateTime(2026, 11, 12),
      priority: 'High',
    ),
    Task(
      title: 'Check expiry, shelf B',
      assignee: 'Aminah',
      due: DateTime(2026, 11, 15),
      priority: 'High',
      status: 'In progress',
    ),
    Task(
      title: 'File supplier invoice',
      assignee: 'Siti',
      due: DateTime(2026, 11, 11),
      priority: 'Low',
      status: 'Done',
    ),
  ];

  static final List<SavedReport> reports = [
    SavedReport(
      title: 'Daily report',
      date: '13 Nov 2026',
      approvedBy: 'Siti',
      body:
          'Daily report, 13 Nov 2026. Twenty items counted, one discrepancy '
          'found (Loratadine 10mg, minus 2). Two activities recorded. '
          'Four tasks open, one overdue.',
    ),
    SavedReport(
      title: 'Handover note',
      date: '13 Nov 2026',
      approvedBy: 'Aminah',
      body:
          'Handover, 13 Nov 2026, morning to evening. Fridge temperature '
          'logged. Recount of ORS sachets still outstanding.',
    ),
  ];

  static List<Task> get openTasks =>
      tasks.where((t) => t.status != 'Done').toList();

  static int get overdueCount => tasks.where((t) => t.isOverdue).length;

  static int get unresolvedDiscrepancies => currentSession.discrepancies;
}
