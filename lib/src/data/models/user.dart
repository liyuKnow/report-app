class User {
  int? id;
  String firstName;
  String lastName;
  int age;
  int? updated;
  String date;

  User({
    required this.firstName,
    required this.lastName,
    required this.age,
    this.updated,
    required this.date,
    this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        updated: json['updated'],
        age: json['age'],
        date: json['date'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'updated': updated,
        'age': age,
        'date': date,
      };
}
