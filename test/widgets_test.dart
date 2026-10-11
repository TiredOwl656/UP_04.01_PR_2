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
    expect(find.text('Ничего не найдено'), findsOneWidget);
  });

  testWidgets('ErrorView показывает кнопку повтора', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            message: 'Ошибка сети',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    expect(find.text('Ошибка сети'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
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
    expect(find.text('Ничего не найдено'), findsOneWidget);
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
            error: 'Ошибка',
            onData: () => const Text('DATA'),
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    expect(find.text('Ошибка'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
    await tester.pump();
    expect(retried, true);
  });
}
