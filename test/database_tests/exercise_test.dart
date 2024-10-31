import 'package:flutter_test/flutter_test.dart';
import 'package:fitnessapp_idata2503/database/tables/exercise.dart';

void main() {
  group('Exercise Tests', () {
    test('Exercise toMap test', () {
      const exercise = Exercise(
        name: 'Push Up',
        description: 'A basic push up exercise',
        category: 'Strength',
        videoUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        lastWeight: 50,
      );

      final exerciseMap = exercise.toMap();

      expect(exerciseMap, {
        'name': 'Push Up',
        'description': 'A basic push up exercise',
        'category': 'Strength',
        'videoUrl': 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        'lastWeight': 50,
      });
    });

    test('Exercise fromMap test', () {
      final exerciseMap = {
        'exerciseId': 1,
        'name': 'Push Up',
        'description': 'A basic push up exercise',
        'category': 'Strength',
        'videoUrl': 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        'lastWeight': 50,
      };

      final exercise = Exercise.fromMap(exerciseMap);

      expect(exercise.exerciseId, 1);
      expect(exercise.name, 'Push Up');
      expect(exercise.description, 'A basic push up exercise');
      expect(exercise.category, 'Strength');
      expect(exercise.videoUrl, 'https://www.youtube.com/watch?v=IODxDxX7oi4');
      expect(exercise.lastWeight, 50);
    });

    test('Exercise fromSqfliteDatabase test', () {
      final exerciseMap = {
        'exerciseID': 1,
        'name': 'Push Up',
        'description': 'A basic push up exercise',
        'category': 'Strength',
        'videoUrl': 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        'lastWeight': 50,
      };

      final exercise = Exercise.fromSqfliteDatabase(exerciseMap);

      expect(exercise.exerciseId, 1);
      expect(exercise.name, 'Push Up');
      expect(exercise.description, 'A basic push up exercise');
      expect(exercise.category, 'Strength');
      expect(exercise.videoUrl, 'https://www.youtube.com/watch?v=IODxDxX7oi4');
      expect(exercise.lastWeight, 50);
    });
  });
}