// ignore_for_file: deprecated_member_use, prefer_interpolation_to_compose_strings
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'advanced_features.dart';

const webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
const apiUrl = String.fromEnvironment('API_BASE_URL');

void main() => runApp(const CsMasterApp());

class CsMasterApp extends StatelessWidget {
  const CsMasterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CS MASTER 12',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff5267d8)), useMaterial3: true),
    home: const Shell(),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  bool busy = false;
  String accountText = 'Guest learning mode';
  final google = GoogleSignIn(scopes: const ['email', 'profile'], serverClientId: webClientId.isEmpty ? null : webClientId);

  Future<void> signIn() async {
    if (webClientId.isEmpty || apiUrl.isEmpty) {
      message('Google sign-in is not configured in this build. Add GOOGLE_WEB_CLIENT_ID and API_BASE_URL, deploy the FastAPI backend over HTTPS, and rebuild. Guest mode works now.');
      return;
    }
    setState(() => busy = true);
    try {
      final account = await google.signIn();
      if (account == null) return;
      final token = (await account.authentication).idToken;
      if (token == null || token.isEmpty) throw Exception('No ID token. Check Web OAuth client ID and Android SHA-1.');
      final response = await http.post(
        Uri.parse(apiUrl.replaceAll(RegExp(r'/+$'), '') + '/api/v1/auth/google'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': token}),
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        var detail = 'API error ' + response.statusCode.toString();
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['detail'] != null) detail = data['detail'].toString();
        } catch (_) {}
        throw Exception(detail);
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (mounted) setState(() => accountText = 'Signed in: ' + (data['user']['name'] ?? 'Student').toString());
    } catch (e) {
      var detail = e.toString().replaceFirst('Exception: ', '');
      final lower = detail.toLowerCase();
      if (lower.contains('developer_error') || lower.contains('sign_in_failed') || lower.contains('12500') || lower.contains('10:')) {
        detail = 'OAuth mismatch. Check package com.lkrkavin.cs_master_12, APK signing SHA-1 and Web OAuth client ID.';
      } else if (lower.contains('socketexception') || lower.contains('connection refused') || lower.contains('failed host lookup')) {
        detail = 'Cannot reach Python API. Check API_BASE_URL and HTTPS deployment.';
      }
      if (mounted) message(detail);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void message(String value) {
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: const Text('Google sign-in'),
      content: Text(value),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [HomePage(open: (v) => setState(() => tab = v), account: accountText), const PythonPage(), const SqlPage(), const IntegrationPage(), const QuizPage()];
    return Scaffold(
      appBar: AppBar(title: const Text('CS MASTER 12'), actions: [
        IconButton(onPressed: busy ? null : signIn, icon: busy ? const CircularProgressIndicator() : const Icon(Icons.account_circle_outlined)),
      ]),
      body: SafeArea(child: IndexedStack(index: tab, children: pages)),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
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
  const HomePage({super.key, required this.open, required this.account});
  final ValueChanged<int> open;
  final String account;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Your Class 12 CS workspace', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    const Text('Learn the concept, study a worked example and practise it.'),
    const SizedBox(height: 12),
    Card(child: ListTile(leading: const Icon(Icons.school), title: Text(account), subtitle: const Text('Lessons are available in offline guest mode.'))),
    const SizedBox(height: 10),
    _Area(title: 'Learning Studio', subtitle: 'Progress, AI tutor, question scanner, coding lab, mock practice, missions and voice read-aloud.', icon: Icons.auto_awesome, tap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedHub()))),
    const SizedBox(height: 10),
    _Area(title: 'Python', subtitle: 'Variables, operators, conditions, loops, collections, functions, files and stacks.', icon: Icons.code, tap: () => open(1)),
    const SizedBox(height: 10),
    _Area(title: 'SQL / MySQL', subtitle: 'Tables, INSERT, UPDATE, SELECT, filters, grouping, aggregates and joins.', icon: Icons.storage, tap: () => open(2)),
    const SizedBox(height: 10),
    _Area(title: 'Python + SQL', subtitle: 'Connect Python to MySQL, execute queries, save changes and fetch records.', icon: Icons.integration_instructions, tap: () => open(3)),
    const SizedBox(height: 10),
    _Area(title: 'Practice & quiz', subtitle: 'Six starter questions with answers, explanations and scoring.', icon: Icons.quiz, tap: () => open(4)),
    const SizedBox(height: 14),
    const _Note(title: 'Study flow', body: 'Read → understand → predict the output → check the answer → practise.'),
  ]);
}

class _Area extends StatelessWidget {
  const _Area({required this.title, required this.subtitle, required this.icon, required this.tap});
  final String title, subtitle;
  final IconData icon;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    leading: CircleAvatar(child: Icon(icon)),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: tap,
  ));
}

class _Note extends StatelessWidget {
  const _Note({required this.title, required this.body});
  final String title, body;
  @override
  Widget build(BuildContext context) => Card(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 6), Text(body)]),
  ));
}

class Lesson {
  const Lesson(this.title, this.explain, this.code, this.real);
  final String title, explain, code, real;
}

class Lessons extends StatelessWidget {
  const Lessons({super.key, required this.title, required this.intro, required this.items});
  final String title, intro;
  final List<Lesson> items;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(title, style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    Text(intro),
    const SizedBox(height: 12),
    ...items.map((x) => Card(margin: const EdgeInsets.only(bottom: 9), child: ExpansionTile(
      title: Text(x.title),
      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(x.explain),
        const SizedBox(height: 8),
        const Text('Worked example', style: TextStyle(fontWeight: FontWeight.bold)),
        _Code(x.code),
        const SizedBox(height: 8),
        const Text('Real-world use', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(x.real),
      ],
    ))),
  ]);
}

class _Code extends StatelessWidget {
  const _Code(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 7),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.inverseSurface, borderRadius: BorderRadius.circular(9)),
    child: SelectableText(value, style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontFamily: 'monospace', fontSize: 13)),
  );
}

class PythonPage extends StatelessWidget {
  const PythonPage({super.key});
  @override
  Widget build(BuildContext context) => const Lessons(title: 'Python programming', intro: 'Python is a high-level language. A program follows instructions to process data and solve a problem.', items: [
    Lesson('1. Variables and data types', 'A variable names a value. Common types: int, float, str, bool and list.', "name = 'Anu'\nmarks = 92\nprint(name, marks)\n# Anu 92", 'A result system stores a student name and marks.'),
    Lesson('2. Operators', 'Arithmetic operators include +, -, *, /, //, %, and **.', 'total = 425\nsubjects = 5\nprint(total / subjects)\n# 85.0', 'A report card calculates the average marks.'),
    Lesson('3. if, elif, else', 'Conditional statements select a path depending on whether a condition is true.', 'marks = 76\nif marks >= 90:\n    grade = "A1"\nelif marks >= 75:\n    grade = "A2"\nelse:\n    grade = "B"\nprint(grade)\n# A2', 'A school portal assigns a grade based on a score.'),
    Lesson('4. for and while loops', 'A for loop iterates over a sequence. A while loop repeats while its condition is true.', 'total = 0\nfor mark in [80, 90, 70]:\n    total += mark\nprint(total)\n# 240', 'A program totals marks across subjects.'),
    Lesson('5. Strings and lists', 'Strings store text. Lists store ordered, mutable collections. Indexing starts at zero.', 'subjects = ["CS", "Maths", "Physics"]\nprint(subjects[0])\nsubjects.append("Chemistry")\nprint(len(subjects))\n# CS, 4', 'An app stores subjects and adds a new elective.'),
    Lesson('6. Dictionaries', 'A dictionary stores key-value pairs. Use a key to retrieve its value.', 'student = {"name": "Anu", "marks": 92}\nprint(student["name"])\n# Anu', 'A student record has fields such as name, roll number and marks.'),
    Lesson('7. Functions', 'A function is reusable code defined with def. Parameters receive values; return gives a result.', 'def percent(total, maximum):\n    return total / maximum * 100\nprint(percent(425, 500))\n# 85.0', 'A school system reuses one percentage function for all students.'),
    Lesson('8. Files and exceptions', 'Files preserve data after a program ends. with closes files; try/except handles expected errors.', 'with open("note.txt", "w") as f:\n    f.write("Revise SQL")\ntry:\n    with open("note.txt") as f:\n        print(f.read())\nexcept FileNotFoundError:\n    print("Missing")', 'A revision app saves notes and handles missing files.'),
    Lesson('9. Stack using a list', 'A stack follows LIFO: Last In, First Out. append pushes; pop removes the top item.', 'stack = []\nstack.append("A")\nstack.append("B")\nprint(stack.pop())\n# B', 'Undo history and browser back history use stack-like behaviour.'),
  ]);
}

class SqlPage extends StatelessWidget {
  const SqlPage({super.key});
  @override
  Widget build(BuildContext context) => const Lessons(title: 'SQL / MySQL', intro: 'SQL retrieves and modifies relational data. MySQL is a database management system that understands SQL.', items: [
    Lesson('1. Database and table', 'A database contains tables. Columns are fields; rows are records. CREATE defines objects.', 'CREATE DATABASE school;\nUSE school;\nCREATE TABLE Student (\n roll_no INT PRIMARY KEY,\n name VARCHAR(30),\n city VARCHAR(25)\n);', 'A school stores student details in a structured Student table.'),
    Lesson('2. INSERT, UPDATE, DELETE', 'INSERT adds rows. UPDATE changes rows. DELETE removes rows. WHERE targets the intended record.', "INSERT INTO Student VALUES (101, 'Anu', 'Chennai');\nUPDATE Student SET city='Madurai' WHERE roll_no=101;\nDELETE FROM Student WHERE roll_no=101;", 'The office updates a student city using the roll number.'),
    Lesson('3. SELECT, WHERE, ORDER BY', 'SELECT retrieves columns. WHERE filters rows. ORDER BY sorts; ASC and DESC choose direction.', 'SELECT name, marks\nFROM Result\nWHERE marks >= 75\nORDER BY marks DESC;', 'A teacher lists students scoring at least 75, highest first.'),
    Lesson('4. Aggregate functions', 'COUNT counts; SUM adds; AVG calculates mean; MIN and MAX return extremes.', 'SELECT COUNT(*), AVG(marks), MAX(marks)\nFROM Result;', 'A teacher calculates class strength, average and highest mark.'),
    Lesson('5. GROUP BY and HAVING', 'GROUP BY forms groups. HAVING filters groups after aggregation; WHERE filters rows before grouping.', 'SELECT city, COUNT(*)\nFROM Student\nGROUP BY city\nHAVING COUNT(*) > 2;', 'The school counts students city-wise and shows cities with more than two.'),
    Lesson('6. Joins', 'A join combines related rows from tables using matching columns.', 'SELECT Student.name, Result.marks\nFROM Student INNER JOIN Result\nON Student.roll_no = Result.roll_no;', 'Names and marks stored in separate tables are shown together.'),
    Lesson('7. Constraints and keys', 'PRIMARY KEY uniquely identifies a row. FOREIGN KEY links tables. NOT NULL requires a value; UNIQUE prevents duplicates.', 'CREATE TABLE Result (\n roll_no INT PRIMARY KEY,\n marks INT NOT NULL,\n FOREIGN KEY (roll_no) REFERENCES Student(roll_no)\n);', 'A result must belong to an existing student record.'),
  ]);
}

class IntegrationPage extends StatelessWidget {
  const IntegrationPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Python + SQL integration', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    const Text('Python controls the program. MySQL stores the records. mysql.connector lets Python send SQL and read results.'),
    const SizedBox(height: 10),
    const _Note(title: 'Real-time example: school result entry', body: 'The school office enters roll number 101 and marks 92. Python receives the values, sends INSERT to MySQL, commits the change, then sends SELECT to read the saved result. The database keeps the record after Python closes.'),
    const _Note(title: '1. Connect', body: 'mysql.connector.connect() opens the connection using host, user, password and database.'),
    const _Note(title: '2. Cursor', body: 'con.cursor() creates the object used to execute SQL and retrieve results.'),
    const _Note(title: '3. Execute', body: 'cursor.execute() sends a query. Use placeholders for user values instead of building SQL by string concatenation.'),
    const _Note(title: '4. Fetch or commit', body: 'fetchone() returns one row; fetchall() returns remaining rows. commit() saves INSERT, UPDATE and DELETE changes.'),
    const _Note(title: '5. Close', body: 'Close the cursor and connection. Real applications should handle exceptions and protect credentials.'),
    const SizedBox(height: 8),
    const Text('Worked Python + MySQL example', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const _Code("""import mysql.connector

con = mysql.connector.connect(
    host="localhost",
    user="root",
    password="YOUR_PASSWORD",
    database="school"
)
cur = con.cursor()

sql = "INSERT INTO Result VALUES (%s, %s)"
values = (101, 92)
cur.execute(sql, values)
con.commit()

cur.execute(
    "SELECT * FROM Result WHERE roll_no = %s",
    (101,)
)
row = cur.fetchone()
print(row)

cur.close()
con.close()"""),
    const _Note(title: 'Expected output idea', body: '(101, 92), assuming the Result table has those two columns and no conflicting row. INSERT saves it; SELECT reads it back.'),
    const _Note(title: 'CBSE terms', body: 'Connection = communication link. Cursor = SQL executor. execute() = send query. fetchone() = read one row. fetchall() = read all rows. commit() = save transaction.'),
  ]);
}

class Question {
  const Question(this.text, this.options, this.answer, this.why);
  final String text, why;
  final List<String> options;
  final int answer;
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  static const qs = [
    Question('What is the output of x=[10,20,30]; print(x[1])?', ['10', '20', '30', 'Error'], 1, 'Index 1 is the second element: 20.'),
    Question('Which keyword defines a Python function?', ['function', 'define', 'def', 'fun'], 2, 'Python uses def.'),
    Question('Which SQL clause filters rows before grouping?', ['HAVING', 'WHERE', 'ORDER BY', 'GROUP BY'], 1, 'WHERE filters rows before grouping.'),
    Question('Which SQL function counts rows?', ['SUM()', 'AVG()', 'COUNT()', 'TOTAL()'], 2, 'COUNT() counts rows or non-NULL values.'),
    Question('Which method saves MySQL changes?', ['fetchall()', 'commit()', 'execute()', 'close()'], 1, 'commit() saves the transaction.'),
    Question('Which cursor method retrieves one row?', ['fetchone()', 'fetchall()', 'one()', 'read()'], 0, 'fetchone() returns the next single row.'),
  ];
  final answers = <int, int>{};
  bool checked = false;
  @override
  Widget build(BuildContext context) {
    final score = qs.asMap().entries.where((e) => answers[e.key] == e.value.answer).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Quick practice', style: Theme.of(context).textTheme.headlineSmall),
      const Text('Answer all six starter questions, then check your score and explanations.'),
      ...qs.asMap().entries.map((e) => Card(margin: const EdgeInsets.only(top: 10), child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Q' + (e.key + 1).toString() + '. ' + e.value.text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ...e.value.options.asMap().entries.map((o) => RadioListTile<int>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: o.key,
            groupValue: answers[e.key],
            onChanged: checked ? null : (v) => setState(() => answers[e.key] = v!),
            title: Text(o.value),
          )),
          if (checked) Text((answers[e.key] == e.value.answer ? 'Correct. ' : 'Correct: ' + e.value.options[e.value.answer] + '. ') + e.value.why),
        ]),
      ))),
      FilledButton(onPressed: answers.length == qs.length ? () => setState(() => checked = true) : null, child: const Text('Check answers')),
      if (checked) ...[
        Text('Score: ' + score.toString() + ' / ' + qs.length.toString(), style: Theme.of(context).textTheme.titleLarge),
        OutlinedButton(onPressed: () => setState(() { answers.clear(); checked = false; }), child: const Text('Try again')),
      ],
    ]);
  }
}
