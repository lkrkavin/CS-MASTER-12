import 'package:flutter_test/flutter_test.dart';
import 'package:cs_master_12/main.dart';

void main() {
  testWidgets('shows the three learning areas', (tester) async {
    await tester.pumpWidget(const CsMasterApp());

    expect(find.text('CS MASTER 12'), findsOneWidget);
    expect(find.text('Python'), findsOneWidget);
    expect(find.text('SQL / MySQL'), findsOneWidget);
    expect(find.text('Python + SQL'), findsOneWidget);
  });
}
