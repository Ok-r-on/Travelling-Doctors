import 'package:flutter/material.dart';

import '../models/case.dart';

class Casetile extends StatelessWidget {
  const Casetile({super.key, required this.caseReport, required this.counter});

  final CaseReport caseReport;
  final int counter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 30,
          // Optionally, add an image or icon here
          child: Icon(Icons.description),
        ),
        title: Text(
          "Case No. ${counter}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text("Diagnosis: ${caseReport.diagnosis}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black,),
        onTap: () {
          _showCaseDetails(context, caseReport);
        },
      ),
    );
  }

  void _showCaseDetails(BuildContext context, CaseReport report) {
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.50,
          minChildSize: 0.5,
          maxChildSize: 1,
          expand: false,
          builder: (context, scrollController) {
            return Container(
                decoration: const BoxDecoration(
                gradient: LinearGradient(
                colors:  [Color.fromARGB(1000, 115, 170, 187),
                  Color.fromARGB(1000, 49, 73, 104),],
                begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
            ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // A close button at the top center
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.cancel, size: 30),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Case No: $counter",
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text("Diagnosis: ${report.diagnosis}", style: TextStyle(fontSize: 16),),
                              const SizedBox(height: 5),
                              Text("Recommendations: ${report.recommendations}", style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 10),
                              Text("Prerequisites: ${report.prerequisites}", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }}
