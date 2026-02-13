import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelling_doctors/components/case_tile.dart';

import '../../auth/auth-service.dart';
import '../../components/caseadd.dart';
import '../../components/caseadd_two.dart';
import '../../components/scanqrcode.dart';
import '../../database/docHomeDB.dart';
import '../../models/case.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> with SingleTickerProviderStateMixin {

  late Future<List<CaseReport>> _futureCaseReports;
  final AuthService _authService = AuthService();
  String _doctorName = "Loading...";


  @override
  void initState() {
    super.initState();
    _futureCaseReports = fetchCaseReportsForCurrentDoctor();
    _fetchDoctorName();
  }

  Future<void> _fetchDoctorName() async {
    final response = await _authService.getPatientName();
    // Update state if data is received, otherwise set to "Unknown"
    setState(() {
      _doctorName = (response != null && response['name'] != null)
          ? response['name']
          : 'Unknown';
    });
  }
  // Function to scan QR code, fetch patient data, and navigate to the add-case page.
  // Navigate to scan page, then fetch patient details using the scanned PatientID,
  // and finally navigate to the Case Report Adding Page.
  Future<void> _scanQRCodeAndAddCase() async {
    /*final patientID = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Scanqrcode()),
    );*/
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CaseReportAddTwoPage(),
      ),
    );
   /*
    final patientID = '4753d919-07e4-45a5-a0b8-60a44fdce83b';

    if (patientID != null) {
      logger.i("Scanned patient ID: $patientID");

      // Query Supabase to retrieve patient details.
      final response = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .eq('id', patientID)
          .single();

      if (response != null && response is Map<String, dynamic>) {
        final patientData = response;
        final String patientName = patientData['name'] ?? "Unknown";
        final int patientAge = patientData['age'] is int
            ? patientData['age']
            : int.tryParse(patientData['age'].toString()) ?? 0;
        final String patientGender = patientData['gender'] ?? "Unknown";

        // Navigate to the Case Report Adding Page with patient details.

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Patient not found")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No QR code scanned")),
      );
    }*/
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child :Column(
          children:[
            Container(
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
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, Dr. $_doctorName",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Manage your tasks, review intern reports, and access patient data efficiently.',
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
            Container(
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
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: _scanQRCodeAndAddCase,
                  splashColor: Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  child: const SizedBox(
                    height: 80,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                        return Casetile(caseReport: report, counter: index+1);
                      },
                    );
                  }
                },
              ),
            ),
          ]
        ),
      ),
    );
  }
}
