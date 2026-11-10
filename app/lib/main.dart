// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

void main() => runApp(const CsMasterApp());

class CsMasterApp extends StatelessWidget {
  const CsMasterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CS MASTER 12',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5267D8)), useMaterial3: true),
    home: const LearningShell(),
  );
}

class LearningShell extends StatefulWidget {
  const LearningShell({super.key});
  @override
  State<LearningShell> createState() => _LearningShellState();
}

class _LearningShellState extends State<LearningShell> {
  int tab = 0;
  bool busy = false;
  Map<String, dynamic>? student;
  final google = GoogleSignIn(scopes: const ['email', 'profile'], serverClientId: googleWebClientId.isEmpty ? null : googleWebClientId);

  Future<void> signIn() async {
    if (googleWebClientId.isEmpty || apiBaseUrl.isEmpty) {
      showAuth('Google sign-in needs two deployment settings: GOOGLE_WEB_CLIENT_ID (Web OAuth client ID) and API_BASE_URL (your deployed HTTPS Python API). Guest mode is ready now; all lessons and practice work without sign-in.');
      return;
    }
    setState(() => busy = true);
    try {
      final account = await google.signIn();
      if (account == null) return;
      final token = (await account.authentication).idToken;
      if (token == null || token.isEmpty) throw Exception('No ID token returned. Check the Web OAuth client ID and Android SHA-1.');
      final response = await http.post(
        Uri.parse('${apiBaseUrl.replaceAll(RegExp(r'/+,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': token}),
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        var detail = 'API sign-in failed (${response.statusCode}).';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['detail'] != null) detail = data['detail'].toString();
        } catch (_) {}
        throw Exception(detail);
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (mounted) setState(() => student = Map<String, dynamic>.from(data['user'] as Map));
    } catch (error) {
      var message = error.toString().replaceFirst('Exception: ', '');
      final lower = message.toLowerCase();
      if (lower.contains('developer_error') || lower.contains('sign_in_failed') || lower.contains('12500') || lower.contains('10:')) {
        message = 'OAuth mismatch: verify Android package com.lkrkavin.cs_master_12, SHA-1 of the installed APK signing key, and the Web OAuth client ID.';
      } else if (lower.contains('socketexception') || lower.contains('connection refused') || lower.contains('failed host lookup')) {
        message = 'Cannot reach the Python API. Check API_BASE_URL, HTTPS deployment and internet connection.';
      } else if (lower.contains('timeout')) {
        message = 'Python API timed out. Check whether your backend is running.';
      }
      if (mounted) showAuth(message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void showAuth(String message) {
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: const Text('Google sign-in'),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  Future<void> signOut() async {
    await google.signOut();
    if (mounted) setState(() => student = null);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(student: student, open: (value) => setState(() => tab = value)),
      const PythonPage(),
      const SqlPage(),
      const IntegrationPage(),
      const PracticePage(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('CS MASTER 12'), actions: [
        if (student != null)
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout), tooltip: 'Sign out')
        else
          IconButton(onPressed: busy ? null : signIn, icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.account_circle_outlined), tooltip: 'Google sign in'),
      ]),
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (value) => setState(() => tab = value), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.code), label: 'Python'),
        NavigationDestination(icon: Icon(Icons.storage), label: 'SQL'),
        NavigationDestination(icon: Icon(Icons.hub_outlined), label: 'Integration'),
        NavigationDestination(icon: Icon(Icons.quiz_outlined), label: 'Practice'),
      ]),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.student, required this.open});
  final Map<String, dynamic>? student;
  final ValueChanged<int> open;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    Text('Your Class 12 CS workspace', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    const Text('Learn a concept, study a worked example, then test your understanding.'),
    const SizedBox(height: 16),
    Card(child: ListTile(leading: const Icon(Icons.school), title: Text(student == null ? 'Guest learning mode' : 'Signed in: ${student!['name'] ?? 'Student'}'), subtitle: Text(student == null ? 'All current lessons are available without Google sign-in.' : (student!['email'] ?? '').toString()))),
    const SizedBox(height: 12),
    _AreaCard(title: 'Python', subtitle: 'Variables, conditions, loops, lists, functions, files and stacks.', icon: Icons.code, onTap: () => open(1)),
    const SizedBox(height: 10),
    _AreaCard(title: 'SQL / MySQL', subtitle: 'Tables, INSERT, SELECT, filters, grouping, aggregates and joins.', icon: Icons.storage, onTap: () => open(2)),
    const SizedBox(height: 10),
    _AreaCard(title: 'Python + SQL', subtitle: 'Connect Python to MySQL, execute queries and fetch results.', icon: Icons.integration_instructions, onTap: () => open(3)),
    const SizedBox(height: 10),
    _AreaCard(title: 'Practice & quiz', subtitle: 'CBSE-style questions with instant answers and explanations.', icon: Icons.quiz_outlined, onTap: () => open(4)),
    const SizedBox(height: 16),
    const _Panel(title: 'Study method', body: 'Read → understand the example → predict the output → check the explanation → solve the quiz.'),
    const SizedBox(height: 10),
    const _Panel(title: 'What works now', body: 'Lessons and quiz run locally. Google account sync needs OAuth client IDs and a deployed backend. No cloud progress sync is claimed yet.'),
  ]);
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    contentPadding: const EdgeInsets.all(16),
    leading: CircleAvatar(child: Icon(icon)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(subtitle)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: onTap,
  ));
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.body});
  final String title, body;
  @override
  Widget build(BuildContext context) => Card(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      Text(body),
    ]),
  ));
}

class _Lesson {
  const _Lesson(this.title, this.explanation, this.code, this.real);
  final String title, explanation, code, real;
}

class _LessonPage extends StatelessWidget {
  const _LessonPage({required this.title, required this.intro, required this.lessons});
  final String title, intro;
  final List<_Lesson> lessons;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(title, style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    Text(intro),
    const SizedBox(height: 14),
    ...lessons.map((lesson) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Card(child: ExpansionTile(
      title: Text(lesson.title),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lesson.explanation),
        const SizedBox(height: 10),
        const Text('Worked example', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _CodePanel(code: lesson.code),
        const SizedBox(height: 10),
        const Text('Real-world example', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(lesson.real),
      ],
    )))),
  ]);
}

class _CodePanel extends StatelessWidget {
  const _CodePanel({required this.code});
  final String code;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.inverseSurface, borderRadius: BorderRadius.circular(10)),
    child: SelectableText(code, style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontFamily: 'monospace', fontSize: 13, height: 1.4)),
  );
}

class PythonPage extends StatelessWidget {
  const PythonPage({super.key});
  @override
  Widget build(BuildContext context) => const _LessonPage(title: 'Python programming', intro: 'Python is a high-level language. A program processes data by following instructions. Expand each topic to see the idea, code and a practical use.', lessons: [
    _Lesson('1. Variables and data types', 'A variable is a name referring to a value. Common types: int, float, str, bool and list.', "student = 'Anu'\nmarks = 92\naverage = marks / 5\nprint(student)\nprint(average)\n\n# Output: Anu, then 18.4", 'A school result program stores a student name and marks, then calculates an average.'),
    _Lesson('2. Operators', 'Arithmetic operators include +, -, *, /, //, %, and **. Python follows operator precedence.', 'total = 425\nsubjects = 5\nprint(total / subjects)\n\n# Output: 85.0', 'A report card calculates a student’s average from the total marks.'),
    _Lesson('3. if, elif and else', 'Conditional statements select a path based on whether a condition is true.', 'marks = 76\nif marks >= 90:\n    grade = "A1"\nelif marks >= 75:\n    grade = "A2"\nelse:\n    grade = "B"\nprint(grade)\n\n# Output: A2', 'A school portal assigns a grade based on the score.'),
    _Lesson('4. for and while loops', 'A for loop iterates over a sequence. A while loop repeats while its condition remains true.', 'total = 0\nfor mark in [80, 90, 70]:\n    total += mark\nprint(total)\n\n# Output: 240', 'A program totals marks for every subject without repeating code.'),
    _Lesson('5. Strings and lists', 'A string stores text. A list stores an ordered, mutable collection. Indexing begins at zero.', 'subjects = ["CS", "Maths", "Physics"]\nprint(subjects[0])\nsubjects.append("Chemistry")\nprint(len(subjects))\n\n# Output: CS, then 4', 'An application stores a student’s subjects and adds an elective.'),
    _Lesson('6. Dictionaries', 'A dictionary stores key-value pairs. Keys retrieve their associated values.', 'student = {"name": "Anu", "marks": 92}\nprint(student["name"])\nprint(student["marks"])', 'A student record contains fields such as name, roll number and marks.'),
    _Lesson('7. Functions', 'A function is reusable code defined with def. Parameters receive values and return sends a result back.', 'def percentage(total, maximum):\n    return total / maximum * 100\nprint(percentage(425, 500))\n\n# Output: 85.0', 'The same percentage function can calculate results for every student.'),
    _Lesson('8. Files and exceptions', 'Files preserve data after a program ends. with closes files automatically; try/except handles expected errors.', 'with open("note.txt", "w") as f:\n    f.write("Revise SQL")\n\ntry:\n    with open("note.txt") as f:\n        print(f.read())\nexcept FileNotFoundError:\n    print("File missing")', 'A program saves revision notes and handles a missing file safely.'),
    _Lesson('9. Stack using a list', 'A stack follows LIFO (Last In, First Out). append() pushes and pop() removes the top item.', 'stack = []\nstack.append("A")\nstack.append("B")\nprint(stack.pop())\nprint(stack)\n\n# B, then ["A"]', 'Undo history and browser back-history can use stack-like behaviour.'),
  ]);
}

class SqlPage extends StatelessWidget {
  const SqlPage({super.key});
  @override
  Widget build(BuildContext context) => const _LessonPage(title: 'SQL / MySQL', intro: 'SQL (Structured Query Language) defines, stores, retrieves and modifies relational data. MySQL is a database system that understands SQL.', lessons: [
    _Lesson('1. Database and table', 'A database contains tables. A table has columns (fields) and rows (records). CREATE defines objects.', 'CREATE DATABASE school;\nUSE school;\nCREATE TABLE Student (\n roll_no INT PRIMARY KEY,\n name VARCHAR(30),\n city VARCHAR(25)\n);', 'A school stores student details in a Student table rather than paper registers.'),
    _Lesson('2. INSERT, UPDATE, DELETE', 'INSERT adds rows. UPDATE changes rows. DELETE removes rows. Use WHERE to target the intended record.', "INSERT INTO Student VALUES (101, 'Anu', 'Chennai');\nUPDATE Student SET city='Madurai' WHERE roll_no=101;\nDELETE FROM Student WHERE roll_no=101;", 'When a student changes city, the office updates the row identified by roll number.'),
    _Lesson('3. SELECT, WHERE, ORDER BY', 'SELECT retrieves columns. WHERE filters rows. ORDER BY sorts; ASC is ascending and DESC descending.', 'SELECT name, marks\nFROM Result\nWHERE marks >= 75\nORDER BY marks DESC;', 'A teacher lists students scoring at least 75, highest marks first.'),
    _Lesson('4. Aggregate functions', 'COUNT counts, SUM adds, AVG calculates mean, MIN and MAX return extremes.', 'SELECT COUNT(*) AS students,\n AVG(marks) AS class_average,\n MAX(marks) AS highest\nFROM Result;', 'A teacher calculates class strength, average and highest score.'),
    _Lesson('5. GROUP BY and HAVING', 'GROUP BY forms groups. HAVING filters groups after aggregation; WHERE filters rows before grouping.', 'SELECT city, COUNT(*) AS total\nFROM Student\nGROUP BY city\nHAVING COUNT(*) > 2;', 'The school counts students city-wise and displays cities with more than two students.'),
    _Lesson('6. Joins', 'A join combines related rows from tables. Matching is commonly done using primary and foreign keys.', 'SELECT Student.name, Result.marks\nFROM Student INNER JOIN Result\nON Student.roll_no = Result.roll_no;', 'Names are stored in Student and marks in Result; the join displays both together.'),
    _Lesson('7. Constraints and keys', 'PRIMARY KEY uniquely identifies a row. FOREIGN KEY links tables. NOT NULL requires a value; UNIQUE prevents duplicates.', 'CREATE TABLE Result (\n roll_no INT PRIMARY KEY,\n marks INT NOT NULL,\n FOREIGN KEY (roll_no) REFERENCES Student(roll_no)\n);', 'A result must belong to an existing student, preventing orphan marks records.'),
  ]);
}

class IntegrationPage extends StatelessWidget {
  const IntegrationPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Python + SQL integration', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    const Text('Python controls the program. MySQL stores the records. mysql.connector lets Python send SQL statements and read the results.'),
    const SizedBox(height: 12),
    const _Panel(title: 'Real-time example: school result entry', body: 'Imagine the school office entering a student’s marks. Python receives the roll number and marks, sends an INSERT query to MySQL, then asks MySQL for that student’s result. The database keeps the record even after Python closes.'),
    const SizedBox(height: 10),
    const _Step(number: '1', title: 'Connect', body: 'Python opens a connection to the MySQL server using mysql.connector and database credentials.'),
    const _Step(number: '2', title: 'Create cursor', body: 'A cursor is the object used to send SQL statements and retrieve query results.'),
    const _Step(number: '3', title: 'Execute', body: 'cursor.execute() sends INSERT, SELECT, UPDATE or DELETE. Use placeholders for values instead of joining raw user input into SQL.'),
    const _Step(number: '4', title: 'Fetch or commit', body: 'Use fetchone() or fetchall() after SELECT. Use commit() after INSERT, UPDATE or DELETE to save changes.'),
    const _Step(number: '5', title: 'Close', body: 'Close cursor and connection. Real applications should handle exceptions and keep passwords out of source code.'),
    const SizedBox(height: 12),
    const Text('Worked Python + MySQL example', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const _CodePanel(code: """import mysql.connector

con = mysql.connector.connect(
    host="localhost",
    user="root",
    password="YOUR_PASSWORD",
    database="school"
)
cur = con.cursor()

# Save a student's result
sql = "INSERT INTO Result VALUES (%s, %s)"
values = (101, 92)
cur.execute(sql, values)
con.commit()

# Read it back
cur.execute(
    "SELECT * FROM Result WHERE roll_no = %s",
    (101,)
)
row = cur.fetchone()
print(row)

cur.close()
con.close()"""),
    const SizedBox(height: 8),
    const _Panel(title: 'Expected idea of output', body: '(101, 92) — exact output depends on the table columns and existing data. INSERT stores the row; SELECT reads it back.'),
    const SizedBox(height: 12),
    const Text('Important CBSE terms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const _Term(term: 'Connection', meaning: 'Communication link between Python and MySQL.'),
    const _Term(term: 'Cursor', meaning: 'Object that executes SQL statements.'),
    const _Term(term: 'execute()', meaning: 'Sends an SQL statement to the database.'),
    const _Term(term: 'fetchone()', meaning: 'Returns the next single row.'),
    const _Term(term: 'fetchall()', meaning: 'Returns all remaining rows.'),
    const _Term(term: 'commit()', meaning: 'Saves the current transaction changes.'),
  ]);
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});
  final String number, title, body;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Card(child: ListTile(
    leading: CircleAvatar(child: Text(number)),
    title: Text(title),
    subtitle: Text(body),
  )));
}

class _Term extends StatelessWidget {
  const _Term({required this.term, required this.meaning});
  final String term, meaning;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 112, child: Text(term, style: const TextStyle(fontWeight: FontWeight.bold))),
    Expanded(child: Text(meaning)),
  ]));
}

class _Question {
  const _Question(this.question, this.options, this.answer, this.explanation);
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
}

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  static const questions = [
    _Question('What is the output? x = [10, 20, 30]; print(x[1])', ['10', '20', '30', 'Error'], 1, 'List indexing starts at zero. x[1] is the second item: 20.'),
    _Question('Which keyword defines a Python function?', ['function', 'define', 'def', 'fun'], 2, 'A Python function is defined with def.'),
    _Question('Which SQL clause filters rows before grouping?', ['HAVING', 'WHERE', 'ORDER BY', 'GROUP BY'], 1, 'WHERE filters individual rows before GROUP BY.'),
    _Question('Which SQL function counts rows?', ['SUM()', 'AVG()', 'COUNT()', 'TOTAL()'], 2, 'COUNT() returns the number of rows (or non-NULL values for a column).'),
    _Question('Which method saves INSERT changes in Python-MySQL?', ['fetchall()', 'commit()', 'execute()', 'close()'], 1, 'commit() confirms the transaction so changes are saved.'),
    _Question('Which cursor method retrieves one row?', ['fetchone()', 'fetchall()', 'one()', 'read()'], 0, 'fetchone() returns the next single row.'),
  ];
  final answers = <int, int>{};
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    final score = questions.asMap().entries.where((entry) => answers[entry.key] == entry.value.answer).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Quick practice', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('Six starter questions from Python, SQL and integration. Select all answers, then check the explanations.'),
      const SizedBox(height: 12),
      ...questions.asMap().entries.map((entry) {
        final i = entry.key;
        final q = entry.value;
        return Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Q${i + 1}. ${q.question}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ...q.options.asMap().entries.map((option) => RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: option.key,
              groupValue: answers[i],
              onChanged: submitted ? null : (value) => setState(() => answers[i] = value!),
              title: Text(option.value),
            )),
            if (submitted)
              Text('${answers[i] == q.answer ? 'Correct. ' : 'Correct answer: ${q.options[q.answer]}. '}${q.explanation}',
                style: TextStyle(color: answers[i] == q.answer ? Colors.green : Theme.of(context).colorScheme.error)),
          ]),
        )));
      }),
      FilledButton(onPressed: answers.length == questions.length ? () => setState(() => submitted = true) : null, child: const Text('Check answers')),
      if (submitted) ...[
        const SizedBox(height: 10),
        Text('Your score: $score / ${questions.length}', style: Theme.of(context).textTheme.titleLarge),
        OutlinedButton(onPressed: () => setState(() { answers.clear(); submitted = false; }), child: const Text('Try again')),
      ],
    ]);
  }
}
), '')}/api/v1/auth/google'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': token}),
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        var detail = 'API sign-in failed (' + response.statusCode.toString() + ').';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['detail'] != null) detail = data['detail'].toString();
        } catch (_) {}
        throw Exception(detail);
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (mounted) setState(() => student = Map<String, dynamic>.from(data['user'] as Map));
    } catch (error) {
      var message = error.toString().replaceFirst('Exception: ', '');
      final lower = message.toLowerCase();
      if (lower.contains('developer_error') || lower.contains('sign_in_failed') || lower.contains('12500') || lower.contains('10:')) {
        message = 'OAuth mismatch: verify Android package com.lkrkavin.cs_master_12, SHA-1 of the installed APK signing key, and the Web OAuth client ID.';
      } else if (lower.contains('socketexception') || lower.contains('connection refused') || lower.contains('failed host lookup')) {
        message = 'Cannot reach the Python API. Check API_BASE_URL, HTTPS deployment and internet connection.';
      } else if (lower.contains('timeout')) {
        message = 'Python API timed out. Check whether your backend is running.';
      }
      if (mounted) showAuth(message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void showAuth(String message) {
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: const Text('Google sign-in'),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  Future<void> signOut() async {
    await google.signOut();
    if (mounted) setState(() => student = null);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(student: student, open: (value) => setState(() => tab = value)),
      const PythonPage(),
      const SqlPage(),
      const IntegrationPage(),
      const PracticePage(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('CS MASTER 12'), actions: [
        if (student != null)
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout), tooltip: 'Sign out')
        else
          IconButton(onPressed: busy ? null : signIn, icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.account_circle_outlined), tooltip: 'Google sign in'),
      ]),
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (value) => setState(() => tab = value), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.code), label: 'Python'),
        NavigationDestination(icon: Icon(Icons.storage), label: 'SQL'),
        NavigationDestination(icon: Icon(Icons.hub_outlined), label: 'Integration'),
        NavigationDestination(icon: Icon(Icons.quiz_outlined), label: 'Practice'),
      ]),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.student, required this.open});
  final Map<String, dynamic>? student;
  final ValueChanged<int> open;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    Text('Your Class 12 CS workspace', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    const Text('Learn a concept, study a worked example, then test your understanding.'),
    const SizedBox(height: 16),
    Card(child: ListTile(leading: const Icon(Icons.school), title: Text(student == null ? 'Guest learning mode' : 'Signed in: ' + (student!['name'] ?? 'Student').toString()), subtitle: Text(student == null ? 'All current lessons are available without Google sign-in.' : (student!['email'] ?? '').toString()))),
    const SizedBox(height: 12),
    _AreaCard(title: 'Python', subtitle: 'Variables, conditions, loops, lists, functions, files and stacks.', icon: Icons.code, onTap: () => open(1)),
    const SizedBox(height: 10),
    _AreaCard(title: 'SQL / MySQL', subtitle: 'Tables, INSERT, SELECT, filters, grouping, aggregates and joins.', icon: Icons.storage, onTap: () => open(2)),
    const SizedBox(height: 10),
    _AreaCard(title: 'Python + SQL', subtitle: 'Connect Python to MySQL, execute queries and fetch results.', icon: Icons.integration_instructions, onTap: () => open(3)),
    const SizedBox(height: 10),
    _AreaCard(title: 'Practice & quiz', subtitle: 'CBSE-style questions with instant answers and explanations.', icon: Icons.quiz_outlined, onTap: () => open(4)),
    const SizedBox(height: 16),
    const _Panel(title: 'Study method', body: 'Read → understand the example → predict the output → check the explanation → solve the quiz.'),
    const SizedBox(height: 10),
    const _Panel(title: 'What works now', body: 'Lessons and quiz run locally. Google account sync needs OAuth client IDs and a deployed backend. No cloud progress sync is claimed yet.'),
  ]);
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    contentPadding: const EdgeInsets.all(16),
    leading: CircleAvatar(child: Icon(icon)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(subtitle)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: onTap,
  ));
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.body});
  final String title, body;
  @override
  Widget build(BuildContext context) => Card(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6),
      Text(body),
    ]),
  ));
}

class _Lesson {
  const _Lesson(this.title, this.explanation, this.code, this.real);
  final String title, explanation, code, real;
}

class _LessonPage extends StatelessWidget {
  const _LessonPage({required this.title, required this.intro, required this.lessons});
  final String title, intro;
  final List<_Lesson> lessons;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(title, style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    Text(intro),
    const SizedBox(height: 14),
    ...lessons.map((lesson) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Card(child: ExpansionTile(
      title: Text(lesson.title),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lesson.explanation),
        const SizedBox(height: 10),
        const Text('Worked example', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _CodePanel(code: lesson.code),
        const SizedBox(height: 10),
        const Text('Real-world example', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(lesson.real),
      ],
    )))),
  ]);
}

class _CodePanel extends StatelessWidget {
  const _CodePanel({required this.code});
  final String code;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.inverseSurface, borderRadius: BorderRadius.circular(10)),
    child: SelectableText(code, style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontFamily: 'monospace', fontSize: 13, height: 1.4)),
  );
}

class PythonPage extends StatelessWidget {
  const PythonPage({super.key});
  @override
  Widget build(BuildContext context) => const _LessonPage(title: 'Python programming', intro: 'Python is a high-level language. A program processes data by following instructions. Expand each topic to see the idea, code and a practical use.', lessons: [
    _Lesson('1. Variables and data types', 'A variable is a name referring to a value. Common types: int, float, str, bool and list.', "student = 'Anu'\nmarks = 92\naverage = marks / 5\nprint(student)\nprint(average)\n\n# Output: Anu, then 18.4", 'A school result program stores a student name and marks, then calculates an average.'),
    _Lesson('2. Operators', 'Arithmetic operators include +, -, *, /, //, %, and **. Python follows operator precedence.', 'total = 425\nsubjects = 5\nprint(total / subjects)\n\n# Output: 85.0', 'A report card calculates a student’s average from the total marks.'),
    _Lesson('3. if, elif and else', 'Conditional statements select a path based on whether a condition is true.', 'marks = 76\nif marks >= 90:\n    grade = "A1"\nelif marks >= 75:\n    grade = "A2"\nelse:\n    grade = "B"\nprint(grade)\n\n# Output: A2', 'A school portal assigns a grade based on the score.'),
    _Lesson('4. for and while loops', 'A for loop iterates over a sequence. A while loop repeats while its condition remains true.', 'total = 0\nfor mark in [80, 90, 70]:\n    total += mark\nprint(total)\n\n# Output: 240', 'A program totals marks for every subject without repeating code.'),
    _Lesson('5. Strings and lists', 'A string stores text. A list stores an ordered, mutable collection. Indexing begins at zero.', 'subjects = ["CS", "Maths", "Physics"]\nprint(subjects[0])\nsubjects.append("Chemistry")\nprint(len(subjects))\n\n# Output: CS, then 4', 'An application stores a student’s subjects and adds an elective.'),
    _Lesson('6. Dictionaries', 'A dictionary stores key-value pairs. Keys retrieve their associated values.', 'student = {"name": "Anu", "marks": 92}\nprint(student["name"])\nprint(student["marks"])', 'A student record contains fields such as name, roll number and marks.'),
    _Lesson('7. Functions', 'A function is reusable code defined with def. Parameters receive values and return sends a result back.', 'def percentage(total, maximum):\n    return total / maximum * 100\nprint(percentage(425, 500))\n\n# Output: 85.0', 'The same percentage function can calculate results for every student.'),
    _Lesson('8. Files and exceptions', 'Files preserve data after a program ends. with closes files automatically; try/except handles expected errors.', 'with open("note.txt", "w") as f:\n    f.write("Revise SQL")\n\ntry:\n    with open("note.txt") as f:\n        print(f.read())\nexcept FileNotFoundError:\n    print("File missing")', 'A program saves revision notes and handles a missing file safely.'),
    _Lesson('9. Stack using a list', 'A stack follows LIFO (Last In, First Out). append() pushes and pop() removes the top item.', 'stack = []\nstack.append("A")\nstack.append("B")\nprint(stack.pop())\nprint(stack)\n\n# B, then ["A"]', 'Undo history and browser back-history can use stack-like behaviour.'),
  ]);
}

class SqlPage extends StatelessWidget {
  const SqlPage({super.key});
  @override
  Widget build(BuildContext context) => const _LessonPage(title: 'SQL / MySQL', intro: 'SQL (Structured Query Language) defines, stores, retrieves and modifies relational data. MySQL is a database system that understands SQL.', lessons: [
    _Lesson('1. Database and table', 'A database contains tables. A table has columns (fields) and rows (records). CREATE defines objects.', 'CREATE DATABASE school;\nUSE school;\nCREATE TABLE Student (\n roll_no INT PRIMARY KEY,\n name VARCHAR(30),\n city VARCHAR(25)\n);', 'A school stores student details in a Student table rather than paper registers.'),
    _Lesson('2. INSERT, UPDATE, DELETE', 'INSERT adds rows. UPDATE changes rows. DELETE removes rows. Use WHERE to target the intended record.', "INSERT INTO Student VALUES (101, 'Anu', 'Chennai');\nUPDATE Student SET city='Madurai' WHERE roll_no=101;\nDELETE FROM Student WHERE roll_no=101;", 'When a student changes city, the office updates the row identified by roll number.'),
    _Lesson('3. SELECT, WHERE, ORDER BY', 'SELECT retrieves columns. WHERE filters rows. ORDER BY sorts; ASC is ascending and DESC descending.', 'SELECT name, marks\nFROM Result\nWHERE marks >= 75\nORDER BY marks DESC;', 'A teacher lists students scoring at least 75, highest marks first.'),
    _Lesson('4. Aggregate functions', 'COUNT counts, SUM adds, AVG calculates mean, MIN and MAX return extremes.', 'SELECT COUNT(*) AS students,\n AVG(marks) AS class_average,\n MAX(marks) AS highest\nFROM Result;', 'A teacher calculates class strength, average and highest score.'),
    _Lesson('5. GROUP BY and HAVING', 'GROUP BY forms groups. HAVING filters groups after aggregation; WHERE filters rows before grouping.', 'SELECT city, COUNT(*) AS total\nFROM Student\nGROUP BY city\nHAVING COUNT(*) > 2;', 'The school counts students city-wise and displays cities with more than two students.'),
    _Lesson('6. Joins', 'A join combines related rows from tables. Matching is commonly done using primary and foreign keys.', 'SELECT Student.name, Result.marks\nFROM Student INNER JOIN Result\nON Student.roll_no = Result.roll_no;', 'Names are stored in Student and marks in Result; the join displays both together.'),
    _Lesson('7. Constraints and keys', 'PRIMARY KEY uniquely identifies a row. FOREIGN KEY links tables. NOT NULL requires a value; UNIQUE prevents duplicates.', 'CREATE TABLE Result (\n roll_no INT PRIMARY KEY,\n marks INT NOT NULL,\n FOREIGN KEY (roll_no) REFERENCES Student(roll_no)\n);', 'A result must belong to an existing student, preventing orphan marks records.'),
  ]);
}

class IntegrationPage extends StatelessWidget {
  const IntegrationPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Python + SQL integration', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    const Text('Python controls the program. MySQL stores the records. mysql.connector lets Python send SQL statements and read the results.'),
    const SizedBox(height: 12),
    const _Panel(title: 'Real-time example: school result entry', body: 'Imagine the school office entering a student’s marks. Python receives the roll number and marks, sends an INSERT query to MySQL, then asks MySQL for that student’s result. The database keeps the record even after Python closes.'),
    const SizedBox(height: 10),
    const _Step(number: '1', title: 'Connect', body: 'Python opens a connection to the MySQL server using mysql.connector and database credentials.'),
    const _Step(number: '2', title: 'Create cursor', body: 'A cursor is the object used to send SQL statements and retrieve query results.'),
    const _Step(number: '3', title: 'Execute', body: 'cursor.execute() sends INSERT, SELECT, UPDATE or DELETE. Use placeholders for values instead of joining raw user input into SQL.'),
    const _Step(number: '4', title: 'Fetch or commit', body: 'Use fetchone() or fetchall() after SELECT. Use commit() after INSERT, UPDATE or DELETE to save changes.'),
    const _Step(number: '5', title: 'Close', body: 'Close cursor and connection. Real applications should handle exceptions and keep passwords out of source code.'),
    const SizedBox(height: 12),
    const Text('Worked Python + MySQL example', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const _CodePanel(code: """import mysql.connector

con = mysql.connector.connect(
    host="localhost",
    user="root",
    password="YOUR_PASSWORD",
    database="school"
)
cur = con.cursor()

# Save a student's result
sql = "INSERT INTO Result VALUES (%s, %s)"
values = (101, 92)
cur.execute(sql, values)
con.commit()

# Read it back
cur.execute(
    "SELECT * FROM Result WHERE roll_no = %s",
    (101,)
)
row = cur.fetchone()
print(row)

cur.close()
con.close()"""),
    const SizedBox(height: 8),
    const _Panel(title: 'Expected idea of output', body: '(101, 92) — exact output depends on the table columns and existing data. INSERT stores the row; SELECT reads it back.'),
    const SizedBox(height: 12),
    const Text('Important CBSE terms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const _Term(term: 'Connection', meaning: 'Communication link between Python and MySQL.'),
    const _Term(term: 'Cursor', meaning: 'Object that executes SQL statements.'),
    const _Term(term: 'execute()', meaning: 'Sends an SQL statement to the database.'),
    const _Term(term: 'fetchone()', meaning: 'Returns the next single row.'),
    const _Term(term: 'fetchall()', meaning: 'Returns all remaining rows.'),
    const _Term(term: 'commit()', meaning: 'Saves the current transaction changes.'),
  ]);
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});
  final String number, title, body;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Card(child: ListTile(
    leading: CircleAvatar(child: Text(number)),
    title: Text(title),
    subtitle: Text(body),
  )));
}

class _Term extends StatelessWidget {
  const _Term({required this.term, required this.meaning});
  final String term, meaning;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 112, child: Text(term, style: const TextStyle(fontWeight: FontWeight.bold))),
    Expanded(child: Text(meaning)),
  ]));
}

class _Question {
  const _Question(this.question, this.options, this.answer, this.explanation);
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
}

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  static const questions = [
    _Question('What is the output? x = [10, 20, 30]; print(x[1])', ['10', '20', '30', 'Error'], 1, 'List indexing starts at zero. x[1] is the second item: 20.'),
    _Question('Which keyword defines a Python function?', ['function', 'define', 'def', 'fun'], 2, 'A Python function is defined with def.'),
    _Question('Which SQL clause filters rows before grouping?', ['HAVING', 'WHERE', 'ORDER BY', 'GROUP BY'], 1, 'WHERE filters individual rows before GROUP BY.'),
    _Question('Which SQL function counts rows?', ['SUM()', 'AVG()', 'COUNT()', 'TOTAL()'], 2, 'COUNT() returns the number of rows (or non-NULL values for a column).'),
    _Question('Which method saves INSERT changes in Python-MySQL?', ['fetchall()', 'commit()', 'execute()', 'close()'], 1, 'commit() confirms the transaction so changes are saved.'),
    _Question('Which cursor method retrieves one row?', ['fetchone()', 'fetchall()', 'one()', 'read()'], 0, 'fetchone() returns the next single row.'),
  ];
  final answers = <int, int>{};
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    final score = questions.asMap().entries.where((entry) => answers[entry.key] == entry.value.answer).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Quick practice', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      const Text('Six starter questions from Python, SQL and integration. Select all answers, then check the explanations.'),
      const SizedBox(height: 12),
      ...questions.asMap().entries.map((entry) {
        final i = entry.key;
        final q = entry.value;
        return Padding(padding: const EdgeInsets.only(bottom: 10), child: Card(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Q' + (i + 1).toString() + '. ' + q.question, style: const TextStyle(fontWeight: FontWeight.bold)),
            ...q.options.asMap().entries.map((option) => RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: option.key,
              groupValue: answers[i],
              onChanged: submitted ? null : (value) => setState(() => answers[i] = value!),
              title: Text(option.value),
            )),
            if (submitted)
              Text((answers[i] == q.answer ? 'Correct. ' : 'Correct answer: ' + q.options[q.answer] + '. ') + q.explanation,
                style: TextStyle(color: answers[i] == q.answer ? Colors.green : Theme.of(context).colorScheme.error)),
          ]),
        )));
      }),
      FilledButton(onPressed: answers.length == questions.length ? () => setState(() => submitted = true) : null, child: const Text('Check answers')),
      if (submitted) ...[
        const SizedBox(height: 10),
        Text('Your score: ' + score.toString() + ' / ' + questions.length.toString(), style: Theme.of(context).textTheme.titleLarge),
        OutlinedButton(onPressed: () => setState(() { answers.clear(); submitted = false; }), child: const Text('Try again')),
      ],
    ]);
  }
}
