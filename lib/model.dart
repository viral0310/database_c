import 'dart:typed_data';

class Student {
  int? id;
  final String name;
  final int age;
  final String city;
  Uint8List? image;

  Student({
    this.id,
    required this.name,
    required this.age,
    required this.city,
    this.image,
  });

  factory Student.fromMap(Map<String, dynamic> data) {
    return Student(
      id: data['id'],
      name: data['name'],
      city: data['city'],
      age: data['age'],
      image: data['image'],
    );
  }
}
