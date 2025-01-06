// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organization _$OrganizationFromJson(Map<String, dynamic> json) => Organization(
      organizationName: json['organizationName'] as String,
      organizationId: json['organizationId'] as String,
      firstLetter: json['firstLetter'] as String,
      children: json['children'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$OrganizationToJson(Organization instance) =>
    <String, dynamic>{
      'organizationId': instance.organizationId,
      'firstLetter': instance.firstLetter,
      'children': instance.children,
      'organizationName': instance.organizationName,
    };
