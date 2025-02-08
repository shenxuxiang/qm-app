import 'package:json_annotation/json_annotation.dart';

part 'location_info.g.dart';

@JsonSerializable()
class LocationInfo {
  @JsonKey(name: 'locationTime')
  final String locationTime;

  @JsonKey(name: 'altitude')
  final double altitude;

  @JsonKey(name: 'longitude')
  final double longitude;

  @JsonKey(name: 'latitude')
  final double latitude;

  @JsonKey(name: 'accuracy')
  final double accuracy;

  @JsonKey(name: 'bearing')
  final double bearing;

  @JsonKey(name: 'speed')
  final double speed;

  @JsonKey(name: 'country')
  final String country;

  @JsonKey(name: 'province')
  final String province;

  @JsonKey(name: 'city')
  final String city;

  @JsonKey(name: 'district')
  final String district;

  @JsonKey(name: 'street')
  final String street;

  @JsonKey(name: 'streetNumber')
  final String streetNumber;

  @JsonKey(name: 'cityCode')
  final String cityCode;

  @JsonKey(name: 'adCode')
  final String adCode;

  @JsonKey(name: 'address')
  final String address;

  @JsonKey(name: 'description')
  final String description;

  const LocationInfo({
    required this.locationTime,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    required this.bearing,
    required this.speed,
    required this.country,
    required this.province,
    required this.city,
    required this.district,
    required this.street,
    required this.streetNumber,
    required this.cityCode,
    required this.adCode,
    required this.address,
    required this.description,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) => _$LocationInfoFromJson(json);

  toJson() => _$LocationInfoToJson(this);
}
