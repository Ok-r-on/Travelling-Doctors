import 'medicine.dart';

class InventoryItem {
  final String id; // inventory row id from doctor_inventory
  final String doctorId;
  final Medicine medicine;
  final int quantity;

  InventoryItem({
    required this.id,
    required this.doctorId,
    required this.medicine,
    required this.quantity,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      doctorId: json['doctor_id'],
      quantity: json['quantity'],
      // The join query returns a nested object "medicines"
      medicine: Medicine.fromJson(json['medicines']),
    );
  }
}
