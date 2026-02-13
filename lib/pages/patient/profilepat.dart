import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/qr_display.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  // Fetch patient profile from Supabase "profiles" table.
  Future<Map<String, dynamic>?> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    // This query assumes that your "profiles" table has fields:
    // id, name, age, gender, email, visits (if visits is stored)
    final response = await Supabase.instance.client
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Error fetching profile")),
          );
        }
        final profile = snapshot.data!;
        // Extract values from the fetched profile.
        final String patientID = profile['id'] ?? 'Unknown ID';
        final String patientName = profile['name'] ?? 'Unknown Name';
        final String patientAge = profile['age']?.toString() ?? 'N/A';
        final String patientGender = profile['gender'] ?? 'N/A';
        // If "visits" is not stored, default to "0" or remove this field.
        // Construct the QR code data string.
        final String qrData =
            "ID:$patientID,Name:$patientName,Age:$patientAge,Gender:$patientGender";

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // QR Placeholder / QR Code
                // Use the QRDisplay widget here
                QRDisplay(qrData: qrData),
                const SizedBox(height: 24),
                // Profile details card
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
                    color: Colors.transparent,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow("Patient Name", patientName),
                          _buildDetailRow("Age", patientAge),
                          _buildDetailRow("Gender", patientGender),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
