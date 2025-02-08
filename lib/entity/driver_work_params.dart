class DriverWorkParams {
  final double workWidth;
  final String workTypeId;
  final String workSeason;
  final String phoneModel;
  final String? deviceCode;

  const DriverWorkParams({
    this.deviceCode,
    required this.workWidth,
    required this.phoneModel,
    required this.workSeason,
    required this.workTypeId,
  });

  factory DriverWorkParams.fromJson(Map<String, dynamic> json) => DriverWorkParams(
        workWidth: json['workWidth'],
        workSeason: json['workSeason'],
        workTypeId: json['workTypeId'],
        deviceCode: json['deviceCode'],
        phoneModel: json['phoneModel'],
      );

  Map<String, dynamic> toJson() {
    return {
      'workWidth': workWidth,
      'workSeason': workSeason,
      'workTypeId': workTypeId,
      'deviceCode': deviceCode,
      'phoneModel': phoneModel,
      'regionCode': '341282104206',
    };
  }
}
