import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory.dart';
import 'package:flutter/material.dart';

class InventoryDB {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<InventoryItem>> fetchInventory() async {
    final doctorId = _client.auth.currentUser!.id;
    final response = await _client
        .from('doctor_inventory')
        .select('*, medicines(*)')
        .eq('doctor_id', doctorId)
        .order('id', ascending: true);

    if (response is List) {
      return response.map((item) => InventoryItem.fromJson(item)).toList();
    } else {
      throw Exception("Error fetching inventory: $response");
    }
  }

  Future<void> addInventoryItem(String medicineName, int quantity, String unit, BuildContext context) async {
    final doctorId = _client.auth.currentUser!.id;

    final res = await _client.from('medicines').select('*').eq('name', medicineName).maybeSingle();
    String medicineId;

    if (res != null) {
      medicineId = res['id'];
    } else {
      final resInsert = await _client.from('medicines').insert({'name': medicineName, 'unit': unit}).select().single();
      if (resInsert == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error adding medicine.")),
        );
        return;
      }
      medicineId = resInsert['id'];
    }

    final resInventory = await _client.from('doctor_inventory').insert({
      'doctor_id': doctorId,
      'medicine_id': medicineId,
      'quantity': quantity,
    }).select().single();

    if (resInventory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error adding inventory.")),
      );
    }
  }

  Future<void> updateInventoryItem(String inventoryId, int newQuantity, BuildContext context) async {
    final res = await _client.from('doctor_inventory').update({
      'quantity': newQuantity,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', inventoryId).select().single();

    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating inventory.")),
      );
    }
  }

  Future<void> deleteInventoryItem(String inventoryId, BuildContext context) async {
    final res = await _client.from('doctor_inventory').delete().eq('id', inventoryId).select().single();

    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting inventory.")),
      );
    }
  }
}