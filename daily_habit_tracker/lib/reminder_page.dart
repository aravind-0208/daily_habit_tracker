import 'package:flutter/material.dart';

class ReminderPage extends StatefulWidget {
  final String username;
  final int percent;

  const ReminderPage({super.key, required this.username, required this.percent});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat();

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = widget.percent == 100;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isComplete ? const [Color(0xFF00BCD4), Color(0xFF0097A7)] : const [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isComplete ? _pulseAnimation.value : 1.0,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                              ),
                              child: Icon(
                                isComplete ? Icons.emoji_events : Icons.trending_up,
                                size: isMobile ? 80 : 100,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: isMobile ? 32 : 48),
                      Text(
                        "Hey ${widget.username} 👋",
                        style: TextStyle(
                          fontSize: isMobile ? 28 : 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isMobile ? 16 : 24),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32, vertical: isMobile ? 14 : 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: Text(
                          "Today's Completion: ${widget.percent}%",
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 24 : 32),
                      Text(
                        widget.percent == 100 ? "🔥 Perfect! You're unstoppable!" : "💪 Keep going! Small steps win.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
                      ),
                      SizedBox(height: isMobile ? 32 : 48),
                      if (isComplete)
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                            ),
                            child: Text(
                              "Great work! You've completed all your habits today.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: isMobile ? 15 : 17, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
