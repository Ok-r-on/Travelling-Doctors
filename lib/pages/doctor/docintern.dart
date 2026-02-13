import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/interntile.dart';

class DoctorViewPage extends StatefulWidget {
  @override
  _DoctorViewPageState createState() => _DoctorViewPageState();
}

class _DoctorViewPageState extends State<DoctorViewPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<String> publicUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchPublicUrls();
  }

  Future<void> _fetchPublicUrls() async {
    try {
      // Retrieve the list of files from the 'resumes' folder in the 'internpdfs' bucket.
      final List<FileObject> files =
          await supabase.storage.from('internpdfs').list(path: 'resumes');

      // For each file, generate its public URL.
      List<String> urls = files.map((file) {
        final fullPath = 'resumes/${file.name}';
        return supabase.storage.from('internpdfs').getPublicUrl(fullPath);
      }).toList();

      // Update the state with the retrieved public URLs.
      setState(() {
        publicUrls = urls;
      });
    } catch (error) {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch resumes: $error')),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // Launch in an external browser
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: publicUrls.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: publicUrls.length,
              itemBuilder: (context, index) {
                final url = publicUrls[index];
                // Extract the file name from the URL
                final fileName = Uri.parse(url).pathSegments.last;
                return InternTile(
                  fileName: fileName,
                  onTap: () {
                    _launchURL(url);
                  },
                );
              },
            ),
    );
  }
}

class ResumePreviewPage extends StatelessWidget {
  final String publicUrl;

  const ResumePreviewPage({Key? key, required this.publicUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
      ),
      body: PDF().cachedFromUrl(
        publicUrl,
        placeholder: (progress) => Center(child: Text('$progress %')),
        errorWidget: (error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
