import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelling_doctors/components/myappbar.dart';
import 'package:travelling_doctors/components/mylogregbutton.dart';
import 'package:travelling_doctors/components/mytextfield.dart';

class InternUploadPage extends StatefulWidget {
  @override
  _InternUploadPageState createState() => _InternUploadPageState();
}

class _InternUploadPageState extends State<InternUploadPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  bool _uploadSuccess = false;

  Future<void> _uploadResume() async {
    final String internName = nameController.text.trim();
    if (internName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    print(result);

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final originalFileName = file.name;
      // The filePath includes the "resumes" folder inside the "internpdfs" bucket.
      final filePath = 'resumes/resume-$internName-$originalFileName.pdf';

      // Check if file exists in the "resumes" folder.
      final existingFiles = await supabase.storage.from('internpdfs').list(
        path: 'resumes',
        searchOptions: SearchOptions(
          search: 'resume-$internName-',
        ),
      );

      // Delete any existing file(s) if found.
      if (existingFiles.isNotEmpty) {
        for (var item in existingFiles) {
          await supabase.storage.from('internpdfs').remove(['resumes/${item.name}']);
        }
      }

      // Upload the new file.
      final response = await supabase.storage.from('internpdfs').upload(
        filePath,
        File(file.path!),
      );

      if (response != null) {
        setState(() {
          _uploadSuccess = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyGradientAppBar(title: 'Upload Resume'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SingleChildScrollView(
            child: Card(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 10,vertical: 30),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20,),
                    MyTextField(hintText: "Enter Your Name Here...", icon: Icons.person_2_rounded,
                    controller: nameController,),
                    const SizedBox(height: 40),
                    MyButton(text: "Upload", onPressed: _uploadResume, icon: Icons.upload,),
                    const SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
          ),
          if (_uploadSuccess)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
            ),
        ],
      ),
    );
  }
}
