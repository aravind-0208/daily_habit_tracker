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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(primary: Color(0xFF667eea)),
      ),
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late String username;
  DateTime selectedDay = DateTime.now();
  Map<String, List<Map<String, dynamic>>> habits = {};
  late AnimationController _progressAnimationController;
  late AnimationController _celebrationController;
  late AnimationController _itemAnimationController;
  late Animation<double> _progressAnimation;
  double _previousPercent = 0;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _celebrationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _itemAnimationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _celebrationController.dispose();
    _itemAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    username = args is String ? args : '';
    loadData();
  }

  String key(DateTime d) => "${d.year}-${d.month}-${d.day}";
  List<Map<String, dynamic>> get today => habits[key(selectedDay)] ?? [];
  int get done => today.where((e) => e["done"]).length;
  double get percent => today.isEmpty ? 0 : (done / today.length);

  Future<void> saveData() async {
    final p = await SharedPreferences.getInstance();
    p.setString("habits", jsonEncode(habits));
  }

  Future<void> loadData() async {
    final p = await SharedPreferences.getInstance();
    final d = p.getString("habits");
    if (d != null) {
      habits = Map<String, List<Map<String, dynamic>>>.from(jsonDecode(d).map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    int percentText = (percent * 100).toInt();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    if (_previousPercent != percent) {
      _previousPercent = percent;
      _progressAnimation = Tween<double>(begin: _progressAnimation.value, end: percent).animate(CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOutCubic));
      _progressAnimationController.forward(from: 0);
      if (percentText == 100) _celebrationController.forward(from: 0);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: isMobile ? 80 : 100,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6C5CE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFFF9800)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: const Color(0xFFFF7043).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          padding: EdgeInsets.all(isMobile ? 8 : 10),
                          child: Icon(Icons.whatshot, color: Colors.white, size: isMobile ? 24 : 32),
                        ),
                        SizedBox(width: isMobile ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Habit Spark",
                                style: TextStyle(
                                  fontSize: isMobile ? 20 : 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                "Welcome back, $username!",
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 13,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 16),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ReminderPage(username: username, percent: percentText)));
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                            ),
                            padding: EdgeInsets.all(isMobile ? 8 : 10),
                            child: Icon(Icons.notifications_active, color: Colors.white, size: isMobile ? 20 : 24),
                          ),
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('username');
                          if (!mounted) return;
                          Navigator.of(context).pushReplacementNamed('/');
                        },
                        icon: Icon(Icons.logout, size: isMobile ? 14 : 16, color: Colors.white),
                        label: Text(
                          "Logout",
                          style: TextStyle(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: isMobile ? 6 : 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F7FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Progress Card
                  Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    shadowColor: const Color(0xFF667eea).withOpacity(0.4),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: EdgeInsets.all(isMobile ? 20 : 32),
                      child: isMobile
                          ? Column(
                              children: [
                              AnimatedBuilder(
                                animation: Listenable.merge([_progressAnimation, _celebrationController]),
                                builder: (context, child) {
                                  double animatedPercent = _progressAnimation.value;
                                  double celebrationScale = 1.0 + (_celebrationController.value * 0.15);
                                  return Transform.scale(
                                    scale: celebrationScale,
                                    child: SizedBox(
                                      height: isMobile ? 100 : 120,
                                      width: isMobile ? 100 : 120,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Background ring
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.15),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: CircularProgressIndicator(
                                              value: animatedPercent,
                                              strokeWidth: isMobile ? 8 : 10,
                                              backgroundColor: Colors.white.withOpacity(0.25),
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Color.lerp(const Color(0xFF26A69A), const Color(0xFF00E5FF), animatedPercent) ?? const Color(0xFF26A69A),
                                              ),
                                              strokeCap: StrokeCap.round,
                                            ),
                                          ),
                                          // Center text with glow effect
                                          Center(
                                            child: Text(
                                              "${(animatedPercent * 100).toInt()}%",
                                              style: TextStyle(
                                                fontSize: isMobile ? 20 : 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                shadows: const [
                                                  Shadow(
                                                    offset: Offset(0, 2),
                                                    blurRadius: 4,
                                                    color: Color.fromARGB(40, 0, 0, 0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: isMobile ? 16 : 0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Today's Goal",
                                    style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.white70, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "$done/${today.length} Completed",
                                    style: TextStyle(fontSize: isMobile ? 20 : 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                    child: Text(
                                      percentText == 100 ? "🔥 All set!" : "$percentText% done",
                                      style: TextStyle(fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AnimatedBuilder(
                                  animation: Listenable.merge([_progressAnimation, _celebrationController]),
                                  builder: (context, child) {
                                    double animatedPercent = _progressAnimation.value;
                                    double celebrationScale = 1.0 + (_celebrationController.value * 0.15);
                                    return Transform.scale(
                                      scale: celebrationScale,
                                      child: SizedBox(
                                        height: 120,
                                        width: 120,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // Background ring
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.15),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: CircularProgressIndicator(
                                                value: animatedPercent,
                                                strokeWidth: 10,
                                                backgroundColor: Colors.white.withOpacity(0.25),
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Color.lerp(const Color(0xFF26A69A), const Color(0xFF00E5FF), animatedPercent) ?? const Color(0xFF26A69A),
                                                ),
                                                strokeCap: StrokeCap.round,
                                              ),
                                            ),
                                            // Center text with glow effect
                                            Center(
                                              child: Text(
                                                "${(animatedPercent * 100).toInt()}%",
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(0, 2),
                                                      blurRadius: 4,
                                                      color: Color.fromARGB(40, 0, 0, 0),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 32),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Today's Goal",
                                        style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "$done/${today.length} Completed",
                                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                        child: Text(
                                          percentText == 100 ? "🔥 All set!" : "$percentText% done",
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 32),
                  // Calendar Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: isMobile ? 16 : 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Date",
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 26,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF667eea),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 6 : 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getDateRange(selectedDay),
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calendar
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: TableCalendar(
                        focusedDay: selectedDay,
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2030),
                        selectedDayPredicate: (d) => isSameDay(d, selectedDay),
                        onDaySelected: (d, _) => setState(() => selectedDay = d),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF667eea)),
                          leftChevronIcon: const Icon(Icons.chevron_left, color: Color(0xFF667eea)),
                          rightChevronIcon: const Icon(Icons.chevron_right, color: Color(0xFF667eea)),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFFF9800)]), borderRadius: BorderRadius.circular(12)),
                          selectedDecoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]), borderRadius: BorderRadius.circular(12)),
                          outsideTextStyle: const TextStyle(color: Colors.grey),
                          todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 32),
                  // Habits Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: isMobile ? 16 : 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Habits",
                          style: TextStyle(fontSize: isMobile ? 18 : 26, fontWeight: FontWeight.bold, color: const Color(0xFF667eea)),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 8 : 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF0097A7)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: const Color(0xFF00BCD4).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: Text(
                            "${today.length} total",
                            style: TextStyle(fontSize: isMobile ? 12 : 13, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            // Habits List
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
              sliver: today.isEmpty
                  ? SliverList(
                      delegate: SliverChildListDelegate([
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 100, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text("No habits yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                                const SizedBox(height: 8),
                                Text("Add one to get started!", style: TextStyle(fontSize: 14, color: Colors.grey[500]))
                              ],
                            ),
                          ),
                        )
                      ]),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              shadowColor: const Color(0xFF667eea).withOpacity(0.2),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: Colors.white,
                                  border: Border.all(color: today[index]["done"] ? const Color(0xFF00BCD4) : Colors.grey[200]!, width: 2),
                                ),
                                child: CheckboxListTile(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  title: Text(
                                    today[index]["name"],
                                    style: TextStyle(
                                      fontSize: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                      color: today[index]["done"] ? const Color(0xFF00BCD4) : Colors.black87,
                                      decoration: today[index]["done"] ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  value: today[index]["done"],
                                  activeColor: const Color(0xFF00BCD4),
                                  checkColor: Colors.white,
                                  secondary: today[index]["done"] ? const Icon(Icons.check_circle, color: Color(0xFF00BCD4), size: 24) : null,
                                  onChanged: (v) {
                                    setState(() => today[index]["done"] = v);
                                    saveData();
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: today.length,
                      ),
                    ),
            ),
            SliverPadding(padding: EdgeInsets.all(isMobile ? 16 : 24)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addHabit,
        elevation: 12,
        backgroundColor: const Color(0xFF26A69A),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  String _getDateRange(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      return "📅 Today";
    } else if (isSameDay(date, now.add(const Duration(days: 1)))) {
      return "📆 Tomorrow";
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return "📋 Yesterday";
    }
    return "${date.day}/${date.month}/${date.year}";
  }

  void addHabit() {
    final c = TextEditingController();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: isMobile ? size.width * 0.85 : 400,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF5F7FF), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: const Color(0xFF667eea).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Add New Habit",
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF667eea),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 20 : 24),
                TextField(
                  controller: c,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Enter habit name",
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.check_circle_outline, color: Color(0xFF667eea)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF667eea), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF667eea), width: 2.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 15),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 12 : 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFF7043), Color(0xFFFF9800)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: const Color(0xFFFF7043).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            if (c.text.isNotEmpty) {
                              habits.putIfAbsent(key(selectedDay), () => []).add({"name": c.text, "done": false});
                              saveData();
                              setState(() {});
                              Navigator.pop(context);
                            }
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                          child: Text(
                            "Add",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}