
import 'package:gistol_dashboard/core/core.dart';

enum SortOrder {
  maxToMin('max_to_min'),
  minToMax('min_to_max');

  final String value;
  const SortOrder(this.value);
  
}



enum SortField {
  date('date'),
  studentsCount('student_count'),
  groupTitle('group_title');
  
  final String value;
  const SortField(this.value);
}
extension SortOrderLocalization on SortOrder {
  String get trKey {
    switch (this) {
      case SortOrder.maxToMin:
        return AppStrings.groups.maxToMin;
      case SortOrder.minToMax:
        return AppStrings.groups.minToMax;
    }
  }
}

extension SortFieldLocalization on SortField {
  String get trKey {
    switch (this) {
      case SortField.date:
        return AppStrings.groups.sortFieldDate;
      case SortField.studentsCount:
        return AppStrings.groups.sortFieldStudents;
      case SortField.groupTitle:
        return AppStrings.groups.sortFieldTitle;
    }
  }
}
class FilterParams {
   SortOrder sortType;
   SortField sortField;
  
   String? title ;
  
   int? minStudentsCount ;
   int? maxStudentsCount ;
  
   DateTime? minDate ;
   DateTime? maxDate ;
  
   int? minYear ;
   int? maxYear ;
  
   bool active;
  
  FilterParams copyWith({
    SortOrder? sortType,
    SortField? sortField,
    String? title,
    int? minStudentsCount,
    int? maxStudentsCount,
    DateTime? minDate,
    DateTime? maxDate,
    int? minYear,
    int? maxYear,
    bool active = true,
    // Обратите внимание на трюк с nullable, чтобы можно было сбросить значение в null (например, снять чекбокс)
    bool clearTitle = false,
  }) {
    return FilterParams(
      sortType: sortType ?? this.sortType,
      sortField: sortField ?? this.sortField,
      title: clearTitle ? null : (title ?? this.title),
      minStudentsCount: minStudentsCount ?? this.minStudentsCount,
      maxStudentsCount: maxStudentsCount ?? this.maxStudentsCount,
      minDate: minDate ?? this.minDate,
      maxDate: maxDate ?? this.maxDate,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      active: active,
    );
  }
  
  FilterParams({
    required this.sortType,
    required this.sortField,
    this.title,
    this.minStudentsCount,
    this.maxStudentsCount,
    this.minDate,
    this.maxDate,
    this.minYear,
    this.maxYear,
    this.active = true
  });
  
  Map<String, String> toQueryParams() {
    return {
      if (title != null) 'title': title!,
      if (minStudentsCount != null) 'min_student_count': minStudentsCount.toString(),
      if (maxStudentsCount != null) 'max_student_count': maxStudentsCount.toString(),
      if (minDate != null) 'min_date': minDate!.toIso8601String(),
      if (maxDate != null) 'max_date': maxDate!.toIso8601String(),
      if (minYear != null) 'min_year': minYear.toString(),
      if (maxYear != null) 'max_year': maxYear.toString(),
      if (active != null) 'active': active.toString(),
      if (sortType != null) 'sort_type': sortType!.value,
      if (sortField != null) 'sort_field': sortField!.value,
    };
  }
}
