import 'location.dart';

class Task {
  String? description;
  String? images;
  MyLocation? location;
  int gmv = 0;
  int discount = 0;

  Task({required this.description, required this.images, required this.location, this.gmv = 0, this.discount = 0});

  Task.fromJson(Map<String, dynamic> json) {
    images = json['images'];
    description = json['description'];
    location = json['location'] != null
        ? new MyLocation.fromJson(json['location'])
        : null;
    gmv = json['gmv'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['images'] = this.images;
    data['description'] = this.description;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['gmv'] = this.gmv;
    data['discount'] = this.discount;
    return data;
  }
}