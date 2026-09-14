
import 'package:flutter/material.dart';
import 'package:gistol_dashboard/core/core.dart';
import 'package:gistol_dashboard/features/groups/domain/filter.dart';
import 'package:gistol_dashboard/features/groups/groups.dart';

class GroupService {
  
  final _api = ApiClient();
  
  Future<WrResponse<YearsResponse>> getYears() async {
    return await _api.get("years/", converter: YearsResponse.converter);
  }
  

  Future<WrResponse<GroupResponse>> getGroups(
    int currentPage,
    int pageSize,
    FilterParams filterParams
  ) async {
    return await _api.get("groups/search", converter: GroupResponse.converter,queryParameters: {
      "page": currentPage,
      "page_size": pageSize,
      ...filterParams.toQueryParams()
    });
  }

  Future<WrResponse<Group>> createGroup(
    GroupCreate data  
  ) async {
    return await _api.post<Group>("groups/", converter: Group.converter,data: data);
  } 
  
  Future<WrResponse<int>> deleteGroups(
    GroupBulkDelete groups 
  ) async {
    return await _api.delete("groups/",data: groups ,converter: (dynamic obj ) => obj as int);
  }

}

