import 'package:flutter_test/flutter_test.dart';
import 'package:login/main.dart';
import 'package:login/services/hive_service.dart';
import 'package:login/services/vlog_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('app shows Vlog Planner home screen', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await HiveService.init();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => VlogProvider(),
        child: const VlogPlannerApp(),
      ),
    );

    expect(find.text('Vlog Planner'), findsOneWidget);
    expect(find.text('No vlogs yet'), findsOneWidget);
  });
}
