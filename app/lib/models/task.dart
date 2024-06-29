import 'location.dart';

class Task {
  final String images;
  final String description;
  final MyLocation location;
  final double gmv; // Estimated price
  final int numTakers = 1;
  double discount = 0;

  Task({
    required this.images,
    required this.description,
    required this.location,
    required this.gmv,
    this.discount = 0,
  });
}