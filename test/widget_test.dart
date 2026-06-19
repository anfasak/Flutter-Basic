import 'package:flutter_test/flutter_test.dart';
import 'package:login/main.dart';
import 'package:login/providers/theme_provider.dart';
import 'package:login/services/hive_service.dart';
import 'package:login/services/vlog_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('app shows CreatorFlow dashboard', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await HiveService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => VlogProvider()),
        ],
        child: const CreatorFlowApp(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('CreatorFlow'), findsOneWidget);
  });
}
