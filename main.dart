import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const PromptMasterApp());

class PromptMasterApp extends StatelessWidget {
  const PromptMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Prompt Master',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1020),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  File? selectedFile;
  String selectedKind = '';
  String result = '';
  final question = TextEditingController();
  final chat = TextEditingController();
  final imagePicker = ImagePicker();
  List<String> saved = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => saved = prefs.getStringList('saved_prompts') ?? []);
  }

  Future<void> _pickImage() async {
    final x = await imagePicker.pickImage(source: ImageSource.gallery);
    if (x != null) setState(() {
      selectedFile = File(x.path);
      selectedKind = 'ছবি';
      result = '';
    });
  }

  Future<void> _pickVideo() async {
    final x = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (x?.files.single.path != null) setState(() {
      selectedFile = File(x!.files.single.path!);
      selectedKind = 'ভিডিও';
      result = '';
    });
  }

  void _generatePrompt() {
    if (selectedFile == null) {
      _message('আগে একটি ছবি বা ভিডিও আপলোড করুন।');
      return;
    }
    _message('আপলোড নির্বাচন সফল হয়েছে। AI বিশ্লেষণ চালু করতে নিরাপদ backend/API সংযোগ প্রয়োজন।');
  }

  Future<void> _savePrompt() async {
    if (result.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    saved.insert(0, result);
    await prefs.setStringList('saved_prompts', saved);
    setState(() {});
    _message('প্রম্পট সেভ হয়েছে।');
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ AI Prompt Master', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: tab,
        children: [_home(), _chatPage(), _savedPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Prompt'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'AI Chat'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline), label: 'Saved'),
        ],
      ),
    );
  }

  Widget _home() => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const Text('ছবি বা ভিডিও থেকে AI Prompt তৈরি করুন',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Upload an image or video and turn it into a detailed cinematic prompt.',
        style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 22),
      Row(children: [
        Expanded(child: _uploadCard(Icons.image_outlined, 'ছবি আপলোড', _pickImage)),
        const SizedBox(width: 12),
        Expanded(child: _uploadCard(Icons.video_library_outlined, 'ভিডিও আপলোড', _pickVideo)),
      ]),
      if (selectedFile != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF18213A), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(selectedKind == 'ছবি' ? Icons.image : Icons.video_file, color: Colors.deepPurpleAccent),
            const SizedBox(width: 10),
            Expanded(child: Text('${selectedKind} নির্বাচন করা হয়েছে\n${selectedFile!.path.split('/').last}',
              maxLines: 2, overflow: TextOverflow.ellipsis)),
            IconButton(onPressed: () => setState(() { selectedFile = null; selectedKind = ''; }), icon: const Icon(Icons.close)),
          ]),
        ),
      ],
      const SizedBox(height: 18),
      FilledButton.icon(
        onPressed: _generatePrompt,
        icon: const Icon(Icons.auto_awesome),
        label: const Padding(padding: EdgeInsets.all(13), child: Text('Generate Cinematic Prompt')),
      ),
      const SizedBox(height: 22),
      const Text('Prompt Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF141C30), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
        child: Text(result.isEmpty ? 'এখানে তৈরি হওয়া প্রম্পট দেখা যাবে।' : result,
          style: const TextStyle(color: Colors.white70)),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: result.isEmpty ? null : _savePrompt, icon: const Icon(Icons.bookmark_add_outlined), label: const Text('Save'))),
        const SizedBox(width: 10),
        Expanded(child: OutlinedButton.icon(onPressed: result.isEmpty ? null : () => _message('Copy সুবিধাটি পরের ধাপে যুক্ত হবে।'), icon: const Icon(Icons.copy), label: const Text('Copy'))),
      ]),
      const SizedBox(height: 18),
      const Text('পরবর্তী ধাপ: AI backend যুক্ত হলে ছবি/ভিডিও বিশ্লেষণ করে স্বয়ংক্রিয় প্রম্পট তৈরি হবে।',
        style: TextStyle(color: Colors.amberAccent, fontSize: 12)),
    ],
  );

  Widget _uploadCard(IconData icon, String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      height: 132,
      decoration: BoxDecoration(
        color: const Color(0xFF171F36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF51418A)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 34, color: const Color(0xFFB9A4FF)),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _chatPage() => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const Text('AI Assistant', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('বাংলা ও English—দুই ভাষায় প্রশ্ন করুন।', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 20),
      TextField(controller: chat, maxLines: 4, decoration: const InputDecoration(
        hintText: 'আপনার প্রশ্ন লিখুন...',
        filled: true,
        border: OutlineInputBorder(),
      )),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: () => _message('AI উত্তর চালু করতে backend/API সংযোগ প্রয়োজন।'),
        icon: const Icon(Icons.send), label: const Text('Ask AI')),
      const SizedBox(height: 18),
      const Text('AI-এর উত্তর এখানে দেখা যাবে।', style: TextStyle(color: Colors.white60)),
    ],
  );

  Widget _savedPage() => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const Text('Saved Prompts', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      if (saved.isEmpty) const Text('এখনো কোনো প্রম্পট সেভ করা হয়নি।', style: TextStyle(color: Colors.white70)),
      ...saved.map((s) => Card(child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(s),
      ))),
    ],
  );
}
