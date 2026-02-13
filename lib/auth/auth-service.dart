import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth
        .signInWithPassword(email: email, password: password);
  }

  //sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
      {required String email,
      required String password,
      required String name,
      required int age,
      required String gender,
      required String role, // 'doctor' or 'patient'
      String? specialization}) async {

    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      final userId = response.user!.id;

      // Insert into profiles
      await _supabase.from('profiles').insert({
        'id': userId,
        'name': name,
        'email': email,
        'age': age,
        'gender': gender,
        'role': role,
      });

      if (role == 'doctor') {
        await _supabase.from('doctors').insert({
          'id': userId,
          'specialization': specialization,
        });
      } else if (role == 'patient') {
        await _supabase.from('patients').insert({
          'id': userId,
        });
      }
    }
    return response;
  }
  //getting user role..
  Future<String?> getUserRole() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    return response['role'] as String?;
  }
  //getting the doctors profile..
  Future<Map<String, dynamic>?> getDoctorProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select('*, doctors(specialization)')
        .eq('id', user.id)
        .single();

    return response;
  }
  //getting patient profile..
  Future<Map<String, dynamic>?> getPatientProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .single();

    return response;
  }
  Future<Map<String, dynamic>?> getPatientName() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return null;

    final response = await _supabase
        .from('profiles')
        .select('name')
        .eq('id', user.id)
        .single();

    return response;
  }

  //sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}