import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


String formatDate(BuildContext context, DateTime date) {
  final month = 'months.${date.month}'.tr();
  return '${date.day} $month ${date.year}';
}
