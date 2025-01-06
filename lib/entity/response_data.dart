import 'package:json_annotation/json_annotation.dart';

part 'response_data.g.dart';

@JsonSerializable()
class ResponseData {
  @JsonKey(name: 'code')
  final int code;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'data')
  final dynamic data;

  const ResponseData({required this.code, required this.message, required this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) => _$ResponseDataFromJson(json);

  toJson() => _$ResponseDataToJson(this);
}
