import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'login_page.dart';
import 'reminder_page.dart';

void main() {
  runApp(const HabitApp());
}

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (_) => const LoginPage(),
        "/home": (_) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String username;
  DateTime selectedDay = DateTime.now();
  Map<String, List<Map<String, dynamic>>> habits = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    username = ModalRoute.of(context)!.settings.arguments as String;
    loadData();
  }

  String key(DateTime d) => "${d.year}-${d.month}-${d.day}";
  List<Map<String, dynamic>> get today => habits[key(selectedDay)] ?? [];
  int get done => today.where((e) => e["done"]).length;

  double get percent =>
      today.isEmpty ? 0 : (done / today.length);

  Future<void> saveData() async {
    final p = await SharedPreferences.getInstance();
    p.setString("habits", jsonEncode(habits));
  }

  Future<void> loadData() async {
    final p = await SharedPreferences.getInstance();
    final d = p.getString("habits");
    if (d != null) {
      habits = Map<String, List<Map<String, dynamic>>>.from(
        jsonDecode(d).map(
          (k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v)),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    int percentText = (percent * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $username 👋", style: const TextStyle(fontSize: 18, color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(242, 251, 8, 8), Color.fromARGB(255, 221, 64, 64)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E2DE2).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('username');
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReminderPage(
                    username: username,
                    percent: percentText,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // PROGRESS CARD
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: percent,
                        strokeWidth: 8,
                        backgroundColor: Colors.white30,
                        color: const Color.fromARGB(255, 13, 214, 70),
                      ),
                      Center(
                        child: Text(
                          "$percentText%",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Progress",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("$done / ${today.length} habits done",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                )
              ],
            ),
          ),

          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            selectedDayPredicate: (d) => isSameDay(d, selectedDay),
            onDaySelected: (d, _) => setState(() => selectedDay = d),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: today.length,
              itemBuilder: (_, i) => Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: CheckboxListTile(
                  title: Text(today[i]["name"]),
                  value: today[i]["done"],
                  activeColor: Colors.green,
                  onChanged: (v) {
                    setState(() => today[i]["done"] = v);
                    saveData();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Habit", style: TextStyle(fontSize: 16, color: Colors.white)),
        onPressed: addHabit,
      ),
    );
  }

  void addHabit() {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("New Habit"),
        content: TextField(controller: c),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              habits.putIfAbsent(key(selectedDay), () => [])
                  .add({"name": c.text, "done": false});
              saveData();
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}