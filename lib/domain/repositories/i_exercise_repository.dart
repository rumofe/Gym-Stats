import '../entities/exercise_template.dart';

abstract interface class IExerciseRepository {
  Future<List<ExerciseTemplate>> getAllTemplates();
  Future<List<ExerciseTemplate>> getTemplatesByMuscle(String muscleGroup);
  Future<List<ExerciseTemplate>> searchTemplates(String query);
  Future<int> insertTemplate(ExerciseTemplate template);
  Future<void> updateTemplate(ExerciseTemplate template);
  Future<void> deleteTemplate(int id);
}
