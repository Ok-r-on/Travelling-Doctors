class Medicine {
  final String id;
  final String name;
  final String? description;
  final String unit;

  Medicine({
    required this.id,
    required this.name,
    this.description,
    required this.unit,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      unit: json['unit'],
    );
  }
}
