import 'dart:js_interop';

import 'package:gistol_dashboard/features/students/domain/student.dart';
import 'package:gistol_dashboard/features/students/view/students_export.dart';
import 'package:web/web.dart' as web;

List<StudentExportRow> studentExportRows(Iterable<Student> students) {
  return [
    for (final student in students)
      StudentExportRow(
        name: student.name?.trim() ?? '',
        surname: student.surname?.trim() ?? '',
        group: student.group?.title.trim() ?? '',
        scores: student.scores,
      ),
  ];
}

void downloadStudentsExcel({
  required List<StudentExportRow> rows,
  required StudentExportLabels labels,
  String filename = 'students.xls',
}) {
  final xml = buildStudentsSpreadsheetXml(rows: rows, labels: labels);
  final href =
      'data:application/vnd.ms-excel;charset=utf-8,${Uri.encodeComponent(xml)}';
  final anchor = web.HTMLAnchorElement()
    ..href = href
    ..download = filename;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}

void printStudentsTable({
  required List<StudentExportRow> rows,
  required StudentExportLabels labels,
}) {
  final html = buildStudentsPrintHtml(rows: rows, labels: labels);
  final iframe = web.HTMLIFrameElement()
    ..setAttribute(
      'style',
      'position:fixed;right:0;bottom:0;width:0;height:0;border:0;',
    );
  iframe.addEventListener(
    'load',
    (web.Event _) {
      iframe.contentWindow?.focus();
      iframe.contentWindow?.print();
    }.toJS,
  );
  web.document.body?.appendChild(iframe);
  iframe.setAttribute('srcdoc', html);
}
