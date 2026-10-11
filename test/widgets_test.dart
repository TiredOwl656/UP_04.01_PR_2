import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pr_2_clothing_store/state/product_list_notifier.dart';
import 'package:pr_2_clothing_store/widgets/state_views.dart';

void main() {
  testWidgets('LoadingView показывает индикатор', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingView())),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('EmptyView показывает иконку и текст', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmptyView())),
    );
    expect(find.byIcon(Icons.search_off), findsOneWidget);
    expect(find.text('\u041d\u0438\u0447\u0435\u0433\u043e \u043d\u0435 \u043d\u0430\u0439\u0434\u0435\u043d\u043e'), findsOneWidget);
  });

  testWidgets('ErrorView показывает кнопку повтора', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: '\u041e\u0448\u0438\u0431\u043a\u0430 \u0441\u0435\u0442\u0438',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    expect(find.text('\u041e\u0448\u0438\u0431\u043a\u0430 \u0441\u0435\u0442\u0438'), findsOneWidget);
    await tester.tap(find.text('\u041f\u043e\u0432\u0442\u043e\u0440\u0438\u0442\u044c'));
    await tester.pump();
    expect(retried, true);
  });

  testWidgets('buildStateView → Loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildStateView(
            status: LoadStatus.loading,
            isEmpty: false,
            error: null,
            onData: () => const Text('DATA'),
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('DATA'), findsNothing);
  });

  testWidgets('buildStateView → Empty при success и пустом', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildStateView(
            status: LoadStatus.success,
            isEmpty: true,
            error: null,
            onData: () => const Text('DATA'),
          ),
        ),
      ),
    );
    expect(find.text('\u041d\u0438\u0447\u0435\u0433\u043e \u043d\u0435 \u043d\u0430\u0439\u0434\u0435\u043d\u043e'), findsOneWidget);
    expect(find.text('DATA'), findsNothing);
  });

  testWidgets('buildStateView → Error с retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildStateView(
            status: LoadStatus.error,
            isEmpty: false,
            error: '\u041e\u0448\u0438\u0431\u043a\u0430',
            onData: () => const Text('DATA'),
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    expect(find.text('\u041e\u0448\u0438\u0431\u043a\u0430'), findsOneWidget);
    await tester.tap(find.text('\u041f\u043e\u0432\u0442\u043e\u0440\u0438\u0442\u044c'));
    await tester.pump();
    expect(retried, true);
  });
}