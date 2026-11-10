import 'package:flutter_test/flutter_test.dart';
import 'package:cs_master_12/main.dart';

void main() {
  testWidgets('home shows the learning workspace', (tester) async {
    await tester.pumpWidget(const CsMasterApp());
    expect(find.text('CS MASTER 12'), findsOneWidget);
    expect(find.text('Your Class 12 CS workspace'), findsOneWidget);
    expect(find.text('Guest learning mode'), findsOneWidget);
  });

  testWidgets('Python, SQL and integration tabs open real lessons', (tester) async {
    await tester.pumpWidget(const CsMasterApp());

    await tester.tap(find.text('Python').last);
    await tester.pumpAndSettle();
    expect(find.text('Python programming'), findsOneWidget);
    expect(find.text('1. Variables and data types'), findsOneWidget);

    await tester.tap(find.text('SQL').last);
    await tester.pumpAndSettle();
    expect(find.text('SQL / MySQL'), findsOneWidget);
    expect(find.text('1. Database and table'), findsOneWidget);

    await tester.tap(find.text('Integration').last);
    await tester.pumpAndSettle();
    expect(find.text('Python + SQL integration'), findsOneWidget);
    expect(find.text('Real-time example: school result entry'), findsOneWidget);
  });

  testWidgets('practice tab presents interactive questions', (tester) async {
    await tester.pumpWidget(const CsMasterApp());
    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
    expect(find.text('Quick practice'), findsOneWidget);
    expect(find.textContaining('Which keyword defines a Python function?'), findsOneWidget);
  });
}


  testWidgets('Learning Studio opens the integrated feature hub', (tester) async {
    await tester.pumpWidget(const CsMasterApp());
    await tester.tap(find.text('Learning Studio'));
    await tester.pumpAndSettle();
    expect(find.text('Your complete CS workspace'), findsOneWidget);
    expect(find.text('AI CS tutor'), findsOneWidget);
    expect(find.text('Question scanner'), findsOneWidget);
    expect(find.text('Coding practice lab'), findsOneWidget);
    expect(find.text('CBSE mock practice'), findsOneWidget);
  });
