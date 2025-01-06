import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';

@JsonSerializable()
class Organization {
  @JsonKey(name: 'organizationId')
  final String organizationId;

  @JsonKey(name: 'firstLetter')
  final String firstLetter;

  @JsonKey(name: 'children')
  final List<dynamic> children;

  @JsonKey(name: 'organizationName')
  final String organizationName;

  const Organization({
    required this.organizationName,
    required this.organizationId,
    required this.firstLetter,
    this.children = const [],
  });

  factory Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);

  toJson() => _$OrganizationToJson(this);
}
