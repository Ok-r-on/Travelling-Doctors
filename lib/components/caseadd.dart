import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CaseReportAddPage extends StatefulWidget {
  final String patientID;
  final String patientName;
  final int patientAge;
  final String patientGender;

  const CaseReportAddPage({
    Key? key,
    required this.patientID,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
  }) : super(key: key);

  @override
  _CaseReportAddPageState createState() => _CaseReportAddPageState();
}

class _CaseReportAddPageState extends State<CaseReportAddPage> {

  final TextEditingController prerequisitesController = TextEditingController();
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController recommendationsController = TextEditingController();
  String _recommendations = '';
  late GenerativeModel _model;

  Future<void> _getRecommendations(String diagnosis) async {
    final prompt =
        'Provide a treatment recommendation (50 words) for the following diagnoses : $diagnosis';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      setState(() {
        print(response.text);
        _recommendations = parseRecommendations(response.text ?? "No recommendation found.");
        toggleContainerVisibility();
      });
    } catch (e) {
      setState(() {
        _recommendations = 'Error: $e';
      });
    }
  }

  String parseRecommendations(String text) {
    final cleaned = text.replaceAll('*', '').trim();

    return cleaned; // Fallback if extraction fails
  }

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
        model: 'gemini-2.0-flash', apiKey: dotenv.env['GEMINI_API_KEY']!);
  }

  bool _isContainerVisible = false;

  void toggleContainerVisibility() {
    setState(() {
      _isContainerVisible = !_isContainerVisible;
    });
  }

  @override
  void dispose() {
    prerequisitesController.dispose();
    diagnosisController.dispose();
    recommendationsController.dispose();
    super.dispose();
  }

  Future<void> saveCaseReport() async {
    final doctorId = Supabase.instance.client.auth.currentUser!.id;
    final response = await Supabase.instance.client.from('case_reports').insert({
      'doc_id': doctorId,
      'patient_id': widget.patientID,
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
      appBar: AppBar(
        title: const Text("Add Case Report"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display patient details (read-only)
              Text("Patient: ${widget.patientName}", style: const TextStyle(fontSize: 18)),
              Text("Age: ${widget.patientAge}", style: const TextStyle(fontSize: 18)),
              Text("Gender: ${widget.patientGender}", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: prerequisitesController,
                decoration: const InputDecoration(labelText: "Prerequisites"),
              ),
              TextField(
                controller: diagnosisController,
                decoration: const InputDecoration(labelText: "Diagnosis"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: (){
                  _getRecommendations(diagnosisController.text);
                },
                child: const Text("Use AI"),
              ),
              TextField(
                controller: recommendationsController,
                decoration: const InputDecoration(labelText: "Recommendations"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveCaseReport,
                child: const Text("Save Case Report"),
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
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
