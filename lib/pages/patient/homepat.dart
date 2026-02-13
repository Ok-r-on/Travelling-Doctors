import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelling_doctors/components/case_tile.dart';

import '../../auth/auth-service.dart';
import '../../database/docHomeDB.dart';
import '../../models/case.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late Future<List<CaseReport>> _futureCaseReports;
  String _patientName = "Loading...";

  @override
  void initState() {
    super.initState();
    _futureCaseReports = fetchCaseReportsForCurrentPatient();
    _fetchPatientName();
  }

  Future<void> _fetchPatientName() async {
    final response = await _authService.getPatientName();
    // Update state if data is received, otherwise set to "Unknown"
    setState(() {
      _patientName = (response != null && response['name'] != null)
          ? response['name']
          : 'Unknown';
    });
  }

  // Function to generate PDF
  Future<void> _generatePDF() async {
    // Fetch patient details from the "profiles" table
    final patientResponse = await _authService.getPatientProfile();

    // Extract patient details
    final String patientName = patientResponse!['name'] ?? "Unknown";
    final String patientAge = (patientResponse['age'] ?? "N/A").toString();
    final String patientGender = patientResponse['gender'] ?? "N/A";

    // Fetch the case reports for the current patient
    final List<CaseReport> reports = await fetchCaseReportsForCurrentPatient();

    // Create the PDF document
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header: HEALROUTE in fancy font (using large, bold style)
              pw.Center(
                child: pw.Text(
                  "HEALROUTE",
                  style: pw.TextStyle(
                    fontSize: 36,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              // Patient Details
              pw.Text("Name: $patientName",
                  style: const pw.TextStyle(fontSize: 18)),
              pw.Text("Age: $patientAge",
                  style: const pw.TextStyle(fontSize: 18)),
              pw.Text("Gender: $patientGender",
                  style: const pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              // Table with case reports
              pw.TableHelper.fromTextArray(
                headers: [
                  "Case Number",
                  "Prerequisites",
                  "Diagnosis",
                  "Recommendation"
                ],
                data: reports.map((report) {
                  return [
                    report.id,
                    report.prerequisites,
                    report.diagnosis,
                    report.recommendations,
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 12),
                cellHeight: 25,
              ),
            ],
          );
        },
      ),
    );
// Save PDF to a temporary directory
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/case_report.pdf");
    await file.writeAsBytes(await pdf.save());

    // Upload PDF to Supabase Storage and retrieve a public URL
    final publicUrl = await uploadPdfAndGetPublicUrl(file);

    // Show QR Code in AlertDialog with the PDF URL
    _showQRCode(publicUrl);
  }

// Uploads the PDF file to Supabase Storage and returns its public URL
  Future<String> uploadPdfAndGetPublicUrl(File file) async {
    final fileName = "case_report_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final response = await Supabase.instance.client.storage
        .from('pdfs') // Ensure you have a storage bucket named 'pdfs'
        .upload(fileName, file);
    if (response == null) {
      throw Exception("Upload failed: ${response}");
    }
    final publicUrlResponse =
        Supabase.instance.client.storage.from('pdfs').getPublicUrl(fileName);
    return publicUrlResponse;
  }

  // Function to show QR Code
  void _showQRCode(String base64String) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                  const Text(
                    "Scan QR to View PDF",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200.0,
                    height: 200.0,
                    child: PrettyQrView.data(
                      data: base64String,
                      decoration: const PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(),
                        background:
                            Colors.transparent, // Ensures QR code visibility
                      ),
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(1000, 115, 170, 187),
                  Color.fromARGB(1000, 49, 73, 104),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, $_patientName",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your care is our responsibility.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // PDF Icon Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Color.fromARGB(1000, 66,110,124)),
                onPressed: _generatePDF,
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<CaseReport>>(
              future: _futureCaseReports,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No case reports found."));
                } else {
                  List<CaseReport> caseReports = snapshot.data!;
                  return ListView.builder(
                    itemCount: caseReports.length,
                    itemBuilder: (context, index) {
                      final report = caseReports[index];
                      return Casetile(caseReport: report, counter: index +1,);
                    },
                  );
                }
              },
            ),
          ),
        ]),
      ),
    );
  }
}
