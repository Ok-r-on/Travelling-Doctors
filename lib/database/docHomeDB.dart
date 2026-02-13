import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/case.dart';

Future<List<CaseReport>> fetchCaseReportsForCurrentDoctor() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    // User is not authenticated.
    return [];
  }

  // Query the case_reports table where doc_id matches the current user's id.
  final response = await Supabase.instance.client
      .from('case_reports')
      .select('*')
      .eq('doc_id', user.id);

  // Since Supabase v2 returns the data directly (a List), map the result.
  if (response is List) {
    return response.map((item) => CaseReport.fromJson(item as Map<String, dynamic>)).toList();
  } else {
    // Handle error as needed.
    return [];
  }
}
Future<List<CaseReport>> fetchCaseReportsForCurrentPatient() async {
  final patientId = Supabase.instance.client.auth.currentUser!.id;
  final response = await Supabase.instance.client
      .from('case_reports')
      .select('*')
      .eq('patient_id', patientId);

  if (response is List) {
    return response
        .map((item) => CaseReport.fromJson(item as Map<String, dynamic>))
        .toList();
  } else {
    return [];
  }
}
