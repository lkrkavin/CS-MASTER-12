import 'package:flutter/material.dart';

void main() {
  runApp(const CsMasterApp());
}

class CsMasterApp extends StatelessWidget {
  const CsMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CS MASTER 12',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5267D8)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const subjects = <_SubjectCardData>[
    _SubjectCardData(
      title: 'Python',
      subtitle: 'Learn concepts, write programs, and practise outputs.',
      icon: Icons.code,
      route: 'python',
    ),
    _SubjectCardData(
      title: 'SQL / MySQL',
      subtitle: 'Learn databases, queries, grouping, and joins.',
      icon: Icons.storage,
      route: 'sql',
    ),
    _SubjectCardData(
      title: 'Python + SQL',
      subtitle: 'Connect Python programs with a database.',
      icon: Icons.integration_instructions,
      route: 'integration',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CS MASTER 12'),
        actions: [
          IconButton(
            tooltip: 'Profile (coming soon)',
            onPressed: () => _showComingSoon(context, 'Student profile'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Your Class 12 CS workspace',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Build strong foundations in Python, SQL, and database connectivity.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            for (final subject in subjects) ...[
              _SubjectCard(data: subject),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('AI study tutor'),
                subtitle: const Text('Question help is planned for a later release.'),
                trailing: const Icon(Icons.lock_outline),
                onTap: () => _showComingSoon(context, 'AI study tutor'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Foundation preview • More learning tools are being built.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is planned, not available yet.')),
    );
  }
}

class _SubjectCardData {
  const _SubjectCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.data});

  final _SubjectCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(data.icon)),
        title: Text(data.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(data.subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${data.title} lessons are being built.')),
          );
        },
      ),
    );
  }
}
