import 'dart:convert';

class Task {
  String taskId;
  String name;
  String images;
  String description;
  Map<String, double> location;
  double gmv;
  double discount;
  String giverUserId;
  String note;

  Task({
    required this.taskId,
    required this.name,
    required this.images,
    required this.description,
    required this.location,
    required this.gmv,
    required this.discount,
    required this.giverUserId,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'name': name,
      'images': images,
      'description': description,
      'location': location,
      'gmv': gmv,
      'discount': discount,
      'giverUserId': giverUserId,
      'note': note,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['taskId'],
      name: map['name'],
      images: map['images'],
      description: map['description'],
      location: Map<String, double>.from(map['location']),
      gmv: map['gmv'],
      discount: map['discount'],
      giverUserId: map['giverUserId'],
      note: map['note'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}

void main() {
  // Mock data instances
  Task task1 = Task(
    taskId: "task001",
    name: "Simple Tasks",
    images: "https://fastly.picsum.photos/id/811/200/300.jpg?hmac=h_NbFElSb3w71ZJbJxKMQg8QNgch87Gbus_L_rsfi6g",
    description: "Thorough cleaning of all rooms and surfaces.",
    location: {"longitude": 10.872013231885978, "latitude": 106.79835315604728},
    gmv: 50.0,
    discount: 0.1,
    giverUserId: "user123",
    note: "Please bring own cleaning supplies.",
  );

  Task task2 = Task(
    taskId: "task002",
    name: "Simple Tasks",
    images: "https://fastly.picsum.photos/id/811/200/300.jpg?hmac=h_NbFElSb3w71ZJbJxKMQg8QNgch87Gbus_L_rsfi6g",
    description: "Trimming hedges, mowing lawn, and weeding.",
    location: {"longitude": 10.870547720263653, "latitude": 106.80659229582793},
    gmv: 80.0,
    discount: 0.15,
    giverUserId: "user456",
    note: "Tools provided; need access to water.",
  );

  Task task3 = Task(
    taskId: "task003",
    name: "Simple Tasks",
    images: "https://fastly.picsum.photos/id/173/200/300.jpg?hmac=9Ed5HxHOL3tFCOiW6UHx6a3hVksxDWc7L7p_WzN9N9Q",
    description: "Daily visits to feed and play with pets.",
    location: {"longitude": 10.878703292898765, "latitude": 106.79685529022137},
    gmv: 30.0,
    discount: 0.05,
    giverUserId: "user789",
    note: "Pets are friendly and well-behaved.",
  );

  Task task4 = Task(
    taskId: "task004",
    name: "Simple Tasks",
    images: "https://fastly.picsum.photos/id/581/200/200.jpg?hmac=l2PTQyeWhW42zIrR020S5LHZ2yrX63cSOgZqpeWM0BA",
    description: "Mathematics tutoring for high school students.",
    location: {"longitude": 10.87926144266384, "latitude": 106.80288998254369}, 
    gmv: 60.0,
    discount: 0.2,
    giverUserId: "user234",
    note: "Student is preparing for upcoming exams.",
  );

  Task task5 = Task(
    taskId: "task005",
    name: "Simple Tasks",
    images: "https://fastly.picsum.photos/id/581/200/200.jpg?hmac=l2PTQyeWhW42zIrR020S5LHZ2yrX63cSOgZqpeWM0BA",
    description: "Repairing plumbing and fixing minor electrical issues.",
    location: {"longitude": 10.875420037836111, "latitude": 106.80081712423907},
    gmv: 100.0,
    discount: 0.0,
    giverUserId: "user567",
    note: "Tools and materials provided by handyman.",
  );

}
