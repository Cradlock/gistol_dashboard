import 'package:flutter_test/flutter_test.dart';
import 'package:gistol_dashboard/features/students/view/students_export.dart';

void main() {
  const labels = StudentExportLabels(
    name: 'Имя',
    surname: 'Фамилия',
    group: 'Группа',
    scores: 'Баллы',
    title: 'Студенты',
  );

  const rows = [
    StudentExportRow(
      name: 'Анна',
      surname: 'Петрова',
      group: 'БПИ-232',
      scores: 7,
    ),
  ];

  test('spreadsheet xml contains selected student cells', () {
    final xml = buildStudentsSpreadsheetXml(rows: rows, labels: labels);

    expect(xml, contains('Имя'));
    expect(xml, contains('Фамилия'));
    expect(xml, contains('Группа'));
    expect(xml, contains('Баллы'));
    expect(xml, contains('Анна'));
    expect(xml, contains('Петрова'));
    expect(xml, contains('БПИ-232'));
    expect(xml, contains('ss:Type="Number">7</Data>'));
  });

  test('print html renders a table with student data', () {
    final html = buildStudentsPrintHtml(rows: rows, labels: labels);

    expect(html, contains('<table>'));
    expect(html, contains('Анна'));
    expect(html, contains('Петрова'));
    expect(html, contains('БПИ-232'));
    expect(html, contains('7'));
  });
}
