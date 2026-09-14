

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/entry/entry.dart';

class GroupDuplicateError extends AppException {
  GroupDuplicateError() 
  : super(
      displayType: ExceptDisplayType.toast, 
      localKey: AppStrings.groups.error_duplicate
  );
}


