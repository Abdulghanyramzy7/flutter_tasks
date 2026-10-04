import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
      ),
      home: const BmiCalcPage(),
    );
  }
}

const List<List<Color>> _cardColors = [
  [Color(0xFFFFE5EC), Color(0xFFFFC2D1)],
  [Color(0xFFE2F0CB), Color(0xFFB5EAD7)],
  [Color(0xFFFFDAC1), Color(0xFFFFB7B2)],
  [Color(0xFFD0F4DE), Color(0xFFA9DEF9)],
  [Color(0xFFE4C1F9), Color(0xFFF6DFEB)],
];

const Color _yellow = Color(0xFFFFD60A);

const InputDecoration _fieldStyle = InputDecoration(
  filled: true,
  fillColor: Color(0xFF2C2C2E),
  hintStyle: TextStyle(color: Colors.grey),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  ),
);

class BmiCalcPage extends StatefulWidget {
  const BmiCalcPage({super.key});

  @override
  State<BmiCalcPage> createState() => _BmiCalcPageState();
}

class _BmiCalcPageState extends State<BmiCalcPage> {
  late Box _box;
  bool loading = true;
  bool onlyFav = false;
  String query = '';
  List<Map<String, dynamic>> notes = [];

  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _box = await Hive.openBox('notesBox');
    await Future.delayed(const Duration(seconds: 5));
    final saved = _box.get('notes', defaultValue: []) as List;
    notes = saved.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    setState(() => loading = false);
  }

  void _showNoteDialog({int? index}) {
    final String oldTitle = index == null ? '' : notes[index]['title'];
    final String oldBody = index == null ? '' : notes[index]['body'];
    _title.text = oldTitle;
    _body.text = oldBody;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) {
          final changed =
              _title.text.trim() != oldTitle || _body.text.trim() != oldBody;

          return AlertDialog(
            backgroundColor: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(index == null ? 'New Note' : 'Edit Note'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _title,
                  style: const TextStyle(color: _yellow),
                  onChanged: (_) => setDialog(() {}),
                  decoration: _fieldStyle.copyWith(hintText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _body,
                  style: const TextStyle(color: _yellow),
                  maxLines: 4,
                  onChanged: (_) => setDialog(() {}),
                  decoration: _fieldStyle.copyWith(hintText: 'Write your idea here...'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _yellow,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade800,
                  disabledForegroundColor: Colors.grey,
                ),
                onPressed: changed
                    ? () {
                        final d = DateTime.now();
                        final note = {
                          'title': _title.text.trim(),
                          'body': _body.text.trim(),
                          'date': '${d.day}/${d.month}/${d.year}',
                          'fav': index == null ? false : notes[index]['fav'],
                        };
                        setState(() {
                          if (index == null) {
                            notes.insert(0, note);
                          } else {
                            notes[index] = note;
                          }
                        });
                        _box.put('notes', notes);
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(index == null ? 'Save' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shown = notes.where((n) {
      final text = '${n['title']} ${n['body']}'.toLowerCase();
      return (!onlyFav || n['fav'] == true) && text.contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFB7B2), Color(0xFFA9DEF9), Color(0xFFE4C1F9)],
                    ).createShader(bounds),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Capture Ideas',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('My Notes',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
                    onPressed: () {
                      if (notes.isEmpty) return;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1C1C1E),
                          title: const Text('Delete all notes?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => notes.clear());
                                _box.put('notes', notes);
                                Navigator.pop(context);
                              },
                              child: const Text('Delete all', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search Notes',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Notes'),
                    selected: !onlyFav,
                    selectedColor: _yellow,
                    labelStyle: TextStyle(color: onlyFav ? Colors.white : Colors.black),
                    onSelected: (_) => setState(() => onlyFav = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Favorites'),
                    selected: onlyFav,
                    selectedColor: _yellow,
                    labelStyle: TextStyle(color: onlyFav ? Colors.black : Colors.white),
                    onSelected: (_) => setState(() => onlyFav = true),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator(color: _yellow))
                    : shown.isEmpty
                        ? const Center(
                            child: Text('No notes yet, tap + to add one!',
                                style: TextStyle(color: Colors.grey, fontSize: 16)),
                          )
                        : GridView.builder(
                            itemCount: shown.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemBuilder: (context, i) {
                              final note = shown[i];
                              final realIndex = notes.indexOf(note);
                              return GestureDetector(
                                onTap: () => _showNoteDialog(index: realIndex),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: _cardColors[realIndex % _cardColors.length],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              note['title'] == '' ? 'Untitled' : note['title'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() => note['fav'] = !(note['fav'] as bool));
                                              _box.put('notes', notes);
                                            },
                                            child: Icon(
                                              note['fav'] == true ? Icons.favorite : Icons.favorite_border,
                                              size: 18,
                                              color: note['fav'] == true ? Colors.red : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          note['body'],
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(note['date'],
                                              style: const TextStyle(color: Colors.black54, fontSize: 11)),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() => notes.removeAt(realIndex));
                                              _box.put('notes', notes);
                                            },
                                            child: const Icon(Icons.delete_outline, size: 18, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _yellow,
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}