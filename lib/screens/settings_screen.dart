import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme_manager.dart';
import '../services/audio_manager.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'auth_wrapper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double musicVolume;
  Future<DocumentSnapshot>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    musicVolume = AudioManager.volumeNotifier.value;
    if (AuthService.currentUser != null) {
      _userDataFuture = DatabaseService.getUserData(AuthService.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, selectedTheme, child) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  ThemeManager.getBackground(),
                  fit: BoxFit.cover,
                ),
              ),
              // ================= OVERLAY =================
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                AudioManager.playClick();
                                Navigator.pop(context, true);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD38E4A), size: 22),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                AudioManager.playClick();
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    backgroundColor: const Color(0xFFFAEBCD),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: const Text("Logout", style: TextStyle(color: Color(0xFF7B4E2B), fontWeight: FontWeight.bold)),
                                    content: const Text("Are you sure you want to logout?", style: TextStyle(color: Color(0xFF8D6E63))),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext, false),
                                        child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialogContext, true),
                                        child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await AuthService.signOut();
                                  if (!context.mounted) return;
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                                    (route) => false,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "SETTINGS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      // ================= PROFILE SECTION =================
                      if (AuthService.isAnonymous)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.orangeAccent,
                                    child: Icon(Icons.person, size: 20, color: Colors.white),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Guest Player",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Login to save your progress permanently",
                              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            _WhitishSettingsAuthButton(
                              onPressed: () async {
                                AudioManager.playClick();
                                final user = await AuthService.signInWithGoogle();
                                if (user != null && context.mounted) {
                                  await AuthService.setLocalGuest(false);
                                  // Sync local progress to the newly logged in account
                                  await DatabaseService.syncLocalProgressToFirestore(user.user!);
                                  
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Successfully logged in and progress synced!")),
                                  );

                                  // Force restart the auth flow to show username setup if needed
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ],
                        )
                      else if (_userDataFuture != null)
                        FutureBuilder<DocumentSnapshot>(
                          future: _userDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)));
                            }
                            
                            // Safe data extraction
                            String username = "Player";
                            String? photoUrl;
                            
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final data = snapshot.data!.data() as Map<String, dynamic>?;
                              if (data != null) {
                                username = data['displayName'] ?? "Player";
                                photoUrl = data['photoUrl'];
                              }
                            }

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(color: Colors.white24, width: 2),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.orangeAccent,
                                            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                                            child: photoUrl == null ? const Icon(Icons.person, size: 20, color: Colors.white) : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            username,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      const SizedBox(height: 40),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Music",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: AudioManager.volumeNotifier,
                        builder: (context, volume, child) {
                          return Slider(
                            value: volume,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              AudioManager.setVolume(value);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: AudioManager.isMutedNotifier,
                            builder: (context, isMuted, child) {
                              return _SettingsIconButton(
                                icon: isMuted ? Icons.volume_off : Icons.volume_up,
                                label: "Mute",
                                color: isMuted ? Colors.redAccent : Colors.green,
                                onPressed: () {
                                  AudioManager.playClick();
                                  AudioManager.toggleMute();
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 40),
                          ValueListenableBuilder<bool>(
                            valueListenable: AudioManager.isVibrationEnabledNotifier,
                            builder: (context, isVibration, child) {
                              return _SettingsIconButton(
                                icon: isVibration ? Icons.vibration : Icons.phonelink_erase,
                                label: "Vibration",
                                color: isVibration ? Colors.blue : Colors.grey,
                                onPressed: () {
                                  AudioManager.playClick();
                                  AudioManager.toggleVibration();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Theme",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _ThemeSelectionButton(
                              isSelected: selectedTheme == 1,
                              imagePath: "assets/images/homebackground1.png",
                              onTap: () {
                                AudioManager.playClick();
                                ThemeManager.saveTheme(1);
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _ThemeSelectionButton(
                              isSelected: selectedTheme == 2,
                              imagePath: "assets/images/homebackground2.png",
                              onTap: () {
                                AudioManager.playClick();
                                ThemeManager.saveTheme(2);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _WhitishSettingsAuthButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _WhitishSettingsAuthButton({required this.onPressed});

  @override
  State<_WhitishSettingsAuthButton> createState() => _WhitishSettingsAuthButtonState();
}

class _WhitishSettingsAuthButtonState extends State<_WhitishSettingsAuthButton> with SingleTickerProviderStateMixin {
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black12, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  "https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg",
                  height: 18,
                  width: 18,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle, color: Colors.grey, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Login with Google",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSelectionButton extends StatefulWidget {
  final bool isSelected;
  final String imagePath;
  final VoidCallback onTap;

  const _ThemeSelectionButton({
    required this.isSelected,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<_ThemeSelectionButton> createState() => _ThemeSelectionButtonState();
}

class _ThemeSelectionButtonState extends State<_ThemeSelectionButton> with SingleTickerProviderStateMixin {
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
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected ? Colors.orange.withValues(alpha: 0.5) : Colors.black26,
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isSelected ? Colors.orange : Colors.white24,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: AssetImage(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _SettingsIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SettingsIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_SettingsIconButton> createState() => _SettingsIconButtonState();
}

class _SettingsIconButtonState extends State<_SettingsIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    Color shadowColor = HSLColor.fromColor(widget.color).withLightness(0.3).toColor();

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
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: shadowColor, offset: const Offset(0, 4), blurRadius: 0),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
