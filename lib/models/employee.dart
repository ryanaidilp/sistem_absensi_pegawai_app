class Employee {
  const Employee({
    this.nip,
    this.name,
    this.phone,
    this.gender,
    this.department,
    this.status,
    this.position,
  });

  final String nip;
  final String name;
  final String phone;
  final String gender;
  final String department;
  final String status;
  final String position;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      nip: json['nip'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      gender: json['gender'] as String,
      department: json['department'] as String,
      status: json['status'] as String,
      position: json['position'] as String,
    );
  }
}
