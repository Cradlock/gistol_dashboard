import 'package:flutter_test/flutter_test.dart';
import 'package:gistol_dashboard/features/exams/domain/exam.dart';

void main() {
  test('exam write request uses backend wire keys and UTC date', () {
    final request = ExamWriteRequest(
      title: 'Midterm',
      theme: 'Algebra',
      startAt: DateTime.parse('2026-09-15T10:00:00+06:00'),
      durationMinutes: 90,
    );

    expect(request.toJson(), {
      'title': 'Midterm',
      'theme': 'Algebra',
      'start_at': '2026-09-15T04:00:00.000Z',
      'duration_minutes': 90,
    });
  });

  test('choice question serializes misspelled backend enum value', () {
    final request = QuestionWriteRequest(
      text: 'Two plus two?',
      type: QuestionType.choice,
      points: 2,
      position: 0,
      choices: const [
        ChoiceWriteRequest(text: '3', isCorrect: false),
        ChoiceWriteRequest(text: '4', isCorrect: true),
      ],
    );

    expect(request.toJson()['type'], 'choise');
    expect(request.toJson()['expected_answer'], isNull);
    expect(request.toJson()['choices'], [
      {'text': '3', 'is_correct': false},
      {'text': '4', 'is_correct': true},
    ]);
  });

  test('input question and nullable target match backend contract', () {
    const question = QuestionWriteRequest(
      text: 'Define x',
      type: QuestionType.input,
      points: 1,
      position: 3,
      expectedAnswer: 'variable',
    );
    const target = TargetWriteRequest(year: 2);

    expect(question.toJson(), {
      'text': 'Define x',
      'type': 'input',
      'points': 1,
      'position': 3,
      'choices': <Map<String, dynamic>>[],
      'expected_answer': 'variable',
    });
    expect(target.toJson(), {'group_id': null, 'year': 2});
  });

  test('teacher session converter keeps every answer field', () {
    final session = TeacherSession.converter({
      'id': 7,
      'user_id': 11,
      'exam_id': 2,
      'exam_title': 'Midterm',
      'exam_theme': 'Algebra',
      'status': 'submitted',
      'started_at': '2026-09-15T04:00:00Z',
      'submitted_at': '2026-09-15T04:30:00Z',
      'reviewed_at': null,
      'score': null,
      'answers': [
        {
          'id': 19,
          'question_id': 4,
          'question_text': 'Define x',
          'question_type': 'input',
          'question_points': 2,
          'choice_id': null,
          'choice_text': null,
          'text': 'variable',
          'awarded_points': null,
          'reviewed_at': null,
          'choices': <dynamic>[],
        },
      ],
    });

    expect(session.answers.single.text, 'variable');
    expect(session.answers.single.awardedPoints, isNull);
  });
}
