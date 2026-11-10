import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');

void main() => runApp(const CsMasterApp());

class CsMasterApp extends StatelessWidget {
  const CsMasterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CS MASTER 12',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5267D8)), useMaterial3: true),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: googleWebClientId.isEmpty ? null : googleWebClientId,
  );
  bool _busy = false;
  String? _error;
  Map<String, dynamic>? _student;

  Future<void> _signIn() async {
    setState(() { _busy = true; _error = null; });
    try {
      if (googleWebClientId.isEmpty) {
        throw Exception('Google OAuth is not configured. Add GOOGLE_WEB_CLIENT_ID when building the app.');
      }
      final account = await _googleSignIn.signIn();
      if (account == null) return;
      final idToken = (await account.authentication).idToken;
      if (idToken == null || idToken.isEmpty) throw Exception('Google did not return an ID token. Check OAuth setup.');
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/v1/auth/google'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body is Map ? body['detail'] ?? 'Sign-in failed' : 'Sign-in failed');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() => _student = Map<String, dynamic>.from(body['user'] as Map));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    if (mounted) setState(() => _student = null);
  }

  @override
  Widget build(BuildContext context) {
    final studentName = _student?['name'] as String?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('CS MASTER 12'),
        actions: [
          if (_student != null)
            IconButton(tooltip: 'Sign out', onPressed: _signOut, icon: const Icon(Icons.logout))
          else
            IconButton(tooltip: 'Google sign in', onPressed: _busy ? null : _signIn, icon: const Icon(Icons.account_circle_outlined)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Your Class 12 CS workspace', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Build strong foundations in Python, SQL, and database connectivity.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _student == null
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Save your learning progress'),
                      const SizedBox(height: 6),
                      const Text('Sign in with Google to create your student profile.'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _busy ? null : _signIn,
                        icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login),
                        label: Text(_busy ? 'Signing in...' : 'Continue with Google'),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                    ])
                  : ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text((studentName?.isNotEmpty ?? false) ? studentName![0].toUpperCase() : 'S')),
                      title: Text('Signed in as $studentName'),
                      subtitle: Text(_student!['email'] as String),
                      trailing: const Icon(Icons.verified, color: Colors.green),
                    ),
              ),
            ),
            const SizedBox(height: 12),
            const _SubjectCard(title: 'Python', subtitle: 'Learn concepts, write programs, and practise outputs.', icon: Icons.code),
            const SizedBox(height: 12),
            const _SubjectCard(title: 'SQL / MySQL', subtitle: 'Learn databases, queries, grouping, and joins.', icon: Icons.storage),
            const SizedBox(height: 12),
            const _SubjectCard(title: 'Python + SQL', subtitle: 'Connect Python programs with a database.', icon: Icons.integration_instructions),
            const SizedBox(height: 12),
            const Card(child: ListTile(leading: Icon(Icons.auto_awesome), title: Text('AI study tutor'), subtitle: Text('Question help is planned for a later release.'), trailing: Icon(Icons.lock_outline))),
            const SizedBox(height: 20),
            Text('Foundation preview • More learning tools are being built.', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(subtitle)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title + ' lessons are being built.'))),
    ),
  );
}
