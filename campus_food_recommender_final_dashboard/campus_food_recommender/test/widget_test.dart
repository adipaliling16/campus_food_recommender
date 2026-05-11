import 'package:campus_food_recommender/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen shows app title', (tester) async {
    await tester.pumpWidget(const CampusFoodApp());
    expect(find.text('Campus Food'), findsOneWidget);
    expect(find.text('Rekomendasi Tempat Makan & Cafe'), findsOneWidget);
  });
}
