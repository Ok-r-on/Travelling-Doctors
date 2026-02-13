import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travelling_doctors/components/mytextfieldinvent.dart';

import 'myappbar.dart';
import 'mylogregbutton.dart';
import 'mytextfield.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.createdAt,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'].toString(),
      name: map['name'] as String,
      age: map['age'] is int
          ? map['age'] as int
          : int.tryParse(map['age'].toString()) ?? 0,
      gender: map['gender'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class CaseReportAddTwoPage extends StatefulWidget {

  const CaseReportAddTwoPage({
    Key? key,
  }) : super(key: key);

  @override
  _CaseReportAddPageTwoState createState() => _CaseReportAddPageTwoState();
}

class _CaseReportAddPageTwoState extends State<CaseReportAddTwoPage> {
  final _formKey = GlobalKey<FormState>();

  List<Patient> _patients = [];
  Patient? _selectedPatient;

  final TextEditingController prerequisitesController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController recommendationsController =
      TextEditingController();

  String _recommendations = '';
  late GenerativeModel _model;
  bool _isContainerVisible = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    final response =
        await Supabase.instance.client.from('profiles')
            .select()
            .eq('role', 'patient');
    print(response);
    if (response != null) {
      final data = response as List;
      setState(() {
        _patients = data.map((e) => Patient.fromMap(e)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching patients: ${response}')),
      );
    }
  }

  Future<void> _getRecommendations(String diagnosis) async {
    final prompt =
        'Provide a treatment recommendation (50 words) for the following diagnosis: $diagnosis';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      setState(() {
        _recommendations = response.text ?? "No recommendation found.";
        _isContainerVisible = true;
      });
    } catch (e) {
      setState(() {
        _recommendations = 'Error: $e';
      });
    }
  }

  Future<void> saveCaseReport() async {
    final doctorId = Supabase.instance.client.auth.currentUser!.id;
    final response =
        await Supabase.instance.client.from('case_reports').insert({
      'doc_id': doctorId,
      'patient_id': _selectedPatient!.id,
      'prerequisites': prerequisitesController.text,
      'diagnosis': diagnosisController.text,
      'recommendations': recommendationsController.text,
    });

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Case report added successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error adding case report")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyGradientAppBar(title: "Add Case Report"),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(1000, 115, 170, 187),
                Color.fromARGB(1000, 49, 73, 104),
              ], // Gradient Colors
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
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Patient dropdown (name field)
                    DropdownButtonFormField<Patient>(
                      decoration: const InputDecoration(
                        labelText: "Select Patient",
                        prefixIcon: Icon(Icons.person),
                      ),
                      value: _selectedPatient,
                      items: _patients.map((patient) {
                        return DropdownMenuItem<Patient>(
                          value: patient,
                          child: Text(patient.name),
                        );
                      }).toList(),
                      onChanged: (Patient? newPatient) {
                        setState(() {
                          _selectedPatient = newPatient;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a patient';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Auto-filled fields for age and gender based on selection
                    if (_selectedPatient != null) ...[
                      MyTextFieldforInvent(
                        hintText: _selectedPatient!.age.toString(),
                        icon: Icons.calendar_today,
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      MyTextFieldforInvent(
                        hintText: _selectedPatient!.gender,
                        icon: Icons.transgender,
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                    ],
                    // Editable fields with validation
                    MyTextField(
                      controller: prerequisitesController,
                      hintText: "Enter Prerequisites",
                      icon: Icons.list,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Prerequisites are required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: diagnosisController,
                      hintText: "Enter Diagnosis",
                      icon: Icons.local_hospital,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Diagnosis is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      text: "Use AI",
                      icon: Icons.smart_toy,
                      onPressed: () =>
                          _getRecommendations(diagnosisController.text),
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      controller: recommendationsController,
                      hintText: "Recommendations",
                      icon: Icons.check_circle,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Recommendations are required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: "Save",
                      icon: Icons.save,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          saveCaseReport();
                        }
                      },
                    ),
                    if (_isContainerVisible) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueGrey, width: 1),
                        ),
                        child: Text(
                          _recommendations,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
