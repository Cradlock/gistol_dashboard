
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/auth/domain/errors.dart';


class YearsResponse {
  final List<int> years;
  
  const YearsResponse({required this.years});

  factory YearsResponse.converter(dynamic json ){
    return YearsResponse( 
      years:(json['years'] as List<dynamic>).cast<int>()
    );
  }

}

class GroupCreate implements ToJsonable {
  final String title;
  final int year;

  GroupCreate({
    required this.title,
    required this.year,
  });
  
  Map<String,dynamic> toJson(){
    return {
      "title":this.title,
      "year":this.year,
    };
  }
  
}

class Group {
  final int id;
  final String title;
  final int year;
  final bool isActive;
  final DateTime createdDate;

  Group({
    required this.id,
    required this.title,
    required this.year,
    required this.isActive,
    required this.createdDate
  });

  factory Group.converter(dynamic json) {

    return Group(
      id: json['id'] as int,
      title: json['title'] as String,
      year: json['year'] as int,
      isActive: json['is_active'] as bool,
      createdDate: DateTime.parse(json['created_date'] as String)
    );
  }
}


class GroupResponse {
  final int total;
  final bool hasNext;
  final List<Group> groups;

  GroupResponse({
    required this.total,
    required this.hasNext,
    required this.groups,
  }); 

  factory GroupResponse.converter(dynamic data) {
    // Безопасно приводим к Map
    final json = data as Map<String, dynamic>;

    return GroupResponse(
      total: json['total'] as int? ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      groups: (json['groups'] as List<dynamic>? ?? [])
          .map((item) => Group.converter(item))
          .toList(),
    );
  }
}





class GroupBulkDelete implements ToJsonable {
  final List<int> ids;
  
  GroupBulkDelete({required this.ids});

  Map<String,dynamic> toJson(){
    return {
      "ids":ids
    };
  }
  
}


