class Student {
  Student({
    this.id,
    required this.name,
    required this.age,
  });

  final int? id;
  final String name;
  final int age;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int,
    );
  }
}
