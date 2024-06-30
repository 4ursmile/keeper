// class MyLocation {
//   final double longitude;
//   final double latitude;
//   final String note;
//
//   MyLocation({
//     required this.longitude,
//     required this.latitude,
//     required this.note,
//   });
//
//   // toJson function to serialize MyLocation object to JSON map
//   Map<String, dynamic> toJson() {
//     return {
//       'longitude': longitude,
//       'latitude': latitude,
//       'note': note,
//     };
//   }
//
//   // fromJson factory function to deserialize JSON map to MyLocation object
//   factory MyLocation.fromJson(Map<String, dynamic> json) {
//     return MyLocation(
//       longitude: json['longitude'],
//       latitude: json['latitude'],
//       note: json['note'],
//     );
//   }
// }

class MyLocation {
  double? longitude;
  double? latitude;
  String? note;

  MyLocation({required this.longitude, required this.latitude, required this.note});

  MyLocation.fromJson(Map<String, dynamic> json) {
    longitude = json['longitude'];
    latitude = json['latitude'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['note'] = this.note;
    return data;
  }
}