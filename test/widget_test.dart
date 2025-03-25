import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('Verify initial To-Do List screen', (WidgetTester tester) async {
    await tester.pumpWidget(ToDoListApp());

    // Verify initial UI elements.
    expect(find.text('To-Do List'), findsOneWidget);
    expect(find.text('Start adding tasks!'), findsOneWidget);
  });
}
