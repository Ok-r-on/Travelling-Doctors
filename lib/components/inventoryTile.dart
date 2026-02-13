// ignore_for_file: must_be_immutable, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class InventoryTiles extends StatelessWidget {
  InventoryTiles({
    super.key,
    required this.MedName,
    required this.AmountOfMed,
    required this.deleteTask,
    required this.updateAmount,
    required this.editTask

  });

  final String MedName;
  final int AmountOfMed;
  Function(BuildContext?)? deleteTask;
  Function(BuildContext?)? editTask;
  final Function(int newAmount) updateAmount; // Callback to update the amount

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15, top: 20),
      child: Slidable(
        endActionPane: ActionPane(motion: StretchMotion(), children: [
          const SizedBox(width: 3,),
          SlidableAction(
            onPressed: deleteTask,
            icon: Icons.delete,
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 3,),
          SlidableAction(
            onPressed: editTask,
            icon: Icons.edit,
            backgroundColor: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          )
        ]),
        child: Opacity(
          opacity: AmountOfMed == 0 ? 0.5 : 1.0,
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(1000, 115, 170, 187),
                    Color.fromARGB(1000, 49, 73, 104),], // Gradient Colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // Align items properly
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Column(
                      children: [
                        Text(
                          MedName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 10,),
                        Text(
                          AmountOfMed.toString(),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: Column(children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward, color: Colors.black,),
                        onPressed: () {
                          updateAmount(AmountOfMed + 1); // Increment amount
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward, color: Colors.black),
                        onPressed: () {
                          if (AmountOfMed > 0) {
                            updateAmount(AmountOfMed - 1);
                          } else {
                            // Show a SnackBar when AmountOfMed is already zero
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('$MedName is already out of stock!'),
                                duration: Duration(
                                    seconds: 1), // Display for 1 seconds
                              ),
                            );
                          }
                        },
                      ),
                    ]),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
