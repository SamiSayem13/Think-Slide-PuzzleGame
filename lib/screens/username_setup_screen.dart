import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/audio_manager.dart';
import '../theme/theme_manager.dart';
import 'splash_screen.dart';

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _submitUsername() async {
    final username = _controller.text.trim();
    
    if (username.isEmpty) {
      setState(() => _errorText = "Please enter a name");
      return;
    }
    
    if (username.length < 3) {
      setState(() => _errorText = "Too short! (min 3)");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final isUnique = await DatabaseService.isUsernameUnique(username);
      
      if (!isUnique) {
        setState(() {
          _isLoading = false;
          _errorText = "Name already taken!";
        });
        return;
      }

      final user = AuthService.currentUser;
      if (user != null) {
        await DatabaseService.createUserProfile(user, username);
        
        // Also save locally so we can restore it during transitions
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_chosen_username', username);
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorText = "Connection error. Try again.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background
              Positioned.fill(
                child: Image.asset(
                  ThemeManager.getBackground(),
                  fit: BoxFit.cover,
                ),
              ),
              // Blur Effect
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: 340,
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E8),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: const Color(0xFFD38E4A),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Cartoonish Header Icon
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD54F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.face_retouching_natural,
                            size: 50,
                            color: Color(0xFF7B4E2B),
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          "New Hero!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7B4E2B),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "What should we call you\nin the global ranking?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8D6E63),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 35),
                        TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          maxLength: 12,
                          style: const TextStyle(
                            color: Color(0xFF4E342E),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: const Color(0xFFE8C872).withValues(alpha: 0.2),
                            hintText: "Your Username",
                            hintStyle: TextStyle(
                              color: const Color(0xFF8D6E63).withValues(alpha: 0.5),
                              fontSize: 18,
                            ),
                            errorText: _errorText,
                            errorStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color(0xFFD38E4A), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color(0xFFD38E4A), width: 3),
                            ),
                          ),
                        ),
                        _isLoading
                            ? const CircularProgressIndicator(color: Color(0xFFD38E4A))
                            : _LetsGoButton(
                                onPressed: () {
                                  AudioManager.playClick();
                                  _submitUsername();
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LetsGoButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _LetsGoButton({required this.onPressed});

  @override
  State<_LetsGoButton> createState() => _LetsGoButtonState();
}

class _LetsGoButtonState extends State<_LetsGoButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(color: Color(0xFF558B2F), offset: Offset(0, 6), blurRadius: 0),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8BC34A),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: const Center(
              child: Text(
                "LET'S GO!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  shadows: [Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
