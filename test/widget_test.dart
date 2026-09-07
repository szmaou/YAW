import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaw/app/app.dart';

void main() {
  testWidgets('YAW app loads', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: YawApp()));
    expect(find.text('YAW'), findsWidgets);
  });
}
