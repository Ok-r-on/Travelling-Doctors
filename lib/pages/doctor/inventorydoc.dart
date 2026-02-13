import 'package:flutter/material.dart';
import 'package:travelling_doctors/components/inventoryTile.dart';
import 'package:travelling_doctors/components/mytextfieldinvent.dart';

import '../../components/mylogregbutton.dart';
import '../../components/mytextfield.dart';
import '../../database/inventDB.dart';
import '../../models/inventory.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final InventoryDB _inventoryDB = InventoryDB();
  List<InventoryItem> inventoryList = [];

  @override
  void initState() {
    super.initState();
    loadInventory();
  }

  Future<void> loadInventory() async {
    final items = await _inventoryDB.fetchInventory();
    setState(() {
      inventoryList = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: inventoryList.length,
        itemBuilder: (context, index) {
          final item = inventoryList[index];
          return InventoryTiles(
            MedName: item.medicine.name,
            AmountOfMed: item.quantity,
            deleteTask: (_) => _inventoryDB
                .deleteInventoryItem(item.id, context)
                .then((_) => loadInventory()),
            editTask: (_) => _showMedicineDialog(item: item),
            updateAmount: (newAmount) => _inventoryDB
                .updateInventoryItem(item.id, newAmount, context)
                .then((_) => loadInventory()),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4286f4), Color(0xFF373B44)], // Your gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle, // Ensures the FAB remains circular
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showMedicineDialog();
          },
          backgroundColor: Colors.transparent, // Transparent so gradient is visible
          elevation: 0, // No shadow since we handle it in BoxDecoration
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),

    );
  }

  // Display a dialog for adding or editing an inventory item.
  void _showMedicineDialog({InventoryItem? item}) {
    final nameController = TextEditingController(text: item?.medicine.name);
    final quantityController =
        TextEditingController(text: item?.quantity.toString());
    final unitController =
        TextEditingController(text: item?.medicine.unit ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(1000, 115, 170, 187),
                    Color.fromARGB(1000, 49, 73, 104),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item == null ? 'Add Medicine' : 'Edit Medicine',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MyTextFieldforInvent(
                      controller: nameController,
                      hintText: 'Medicine Name',
                      icon: Icons.medication,
                      readOnly: item != null, // Prevent editing if item exists
                    ),
                    const SizedBox(height: 16),
                    MyTextFieldforInvent(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      hintText: 'Quantity',
                      icon: Icons.production_quantity_limits,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text(
                            item == null ? 'Add' : 'Save',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                          onPressed: () {
                            final medicineName = nameController.text.trim();
                            final quantity =
                                int.tryParse(quantityController.text.trim()) ?? 0;
                            final unit = unitController.text.trim();
                            if (medicineName.isNotEmpty && quantity > 0) {
                              if (item == null) {
                                _inventoryDB
                                    .addInventoryItem(
                                        medicineName, quantity, unit, context)
                                    .then((_) => loadInventory());
                              } else {
                                _inventoryDB
                                    .updateInventoryItem(
                                        item.id, quantity, context)
                                    .then((_) => loadInventory());
                              }
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
