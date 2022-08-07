import 'package:flutter/material.dart';

@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });

  // named constructor
  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'];
}
