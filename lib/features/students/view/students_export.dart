class StudentExportRow {
  final String name;
  final String surname;
  final String group;
  final int scores;

  const StudentExportRow({
    required this.name,
    required this.surname,
    required this.group,
    required this.scores,
  });
}

class StudentExportLabels {
  final String name;
  final String surname;
  final String group;
  final String scores;
  final String title;

  const StudentExportLabels({
    required this.name,
    required this.surname,
    required this.group,
    required this.scores,
    required this.title,
  });
}

String _escapeXml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

String buildStudentsSpreadsheetXml({
  required List<StudentExportRow> rows,
  required StudentExportLabels labels,
}) {
  final buffer = StringBuffer()
    ..writeln('<?xml version="1.0"?>')
    ..writeln('<?mso-application progid="Excel.Sheet"?>')
    ..writeln(
      '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" '
      'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">',
    )
    ..writeln('<Worksheet ss:Name="${_escapeXml(labels.title)}">')
    ..writeln('<Table>')
    ..writeln('<Row>')
    ..writeln(
      '<Cell><Data ss:Type="String">${_escapeXml(labels.name)}</Data></Cell>',
    )
    ..writeln(
      '<Cell><Data ss:Type="String">${_escapeXml(labels.surname)}</Data></Cell>',
    )
    ..writeln(
      '<Cell><Data ss:Type="String">${_escapeXml(labels.group)}</Data></Cell>',
    )
    ..writeln(
      '<Cell><Data ss:Type="String">${_escapeXml(labels.scores)}</Data></Cell>',
    )
    ..writeln('</Row>');

  for (final row in rows) {
    buffer
      ..writeln('<Row>')
      ..writeln(
        '<Cell><Data ss:Type="String">${_escapeXml(row.name)}</Data></Cell>',
      )
      ..writeln(
        '<Cell><Data ss:Type="String">${_escapeXml(row.surname)}</Data></Cell>',
      )
      ..writeln(
        '<Cell><Data ss:Type="String">${_escapeXml(row.group)}</Data></Cell>',
      )
      ..writeln(
        '<Cell><Data ss:Type="Number">${row.scores}</Data></Cell>',
      )
      ..writeln('</Row>');
  }

  buffer
    ..writeln('</Table>')
    ..writeln('</Worksheet>')
    ..writeln('</Workbook>');
  return buffer.toString();
}

String buildStudentsPrintHtml({
  required List<StudentExportRow> rows,
  required StudentExportLabels labels,
}) {
  final buffer = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html><head><meta charset="utf-8">')
    ..writeln('<title>${_escapeXml(labels.title)}</title>')
    ..writeln('<style>')
    ..writeln('body{font-family:sans-serif;margin:24px;}')
    ..writeln('h1{font-size:20px;margin:0 0 16px;}')
    ..writeln('table{border-collapse:collapse;width:100%;}')
    ..writeln('th,td{border:1px solid #333;padding:8px 10px;text-align:left;}')
    ..writeln('th{background:#eee;}')
    ..writeln('@media print{body{margin:0;}}')
    ..writeln('</style></head><body>')
    ..writeln('<h1>${_escapeXml(labels.title)}</h1>')
    ..writeln('<table><thead><tr>')
    ..writeln('<th>${_escapeXml(labels.name)}</th>')
    ..writeln('<th>${_escapeXml(labels.surname)}</th>')
    ..writeln('<th>${_escapeXml(labels.group)}</th>')
    ..writeln('<th>${_escapeXml(labels.scores)}</th>')
    ..writeln('</tr></thead><tbody>');

  for (final row in rows) {
    buffer
      ..writeln('<tr>')
      ..writeln('<td>${_escapeXml(row.name)}</td>')
      ..writeln('<td>${_escapeXml(row.surname)}</td>')
      ..writeln('<td>${_escapeXml(row.group)}</td>')
      ..writeln('<td>${row.scores}</td>')
      ..writeln('</tr>');
  }

  buffer.writeln('</tbody></table></body></html>');
  return buffer.toString();
}
