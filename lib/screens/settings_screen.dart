import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';
import '../services/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double musicVolume = .7;

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
              // ================= BLUR EFFECT =================
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.18),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            enableFeedback: false,
                            onPressed: () {
                              AudioManager.playClick();
                              Navigator.pop(context, true);
                            },
                          ),
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
                      const SizedBox(height: 50),
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
                      Slider(
                        value: musicVolume,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            musicVolume = value;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
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
                            child: GestureDetector(
                              onTap: () {
                                AudioManager.playClick();
                                ThemeManager.saveTheme(1);
                              },
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedTheme == 1
                                        ? Colors.orange
                                        : Colors.white,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      "assets/images/homebackground1.png",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                AudioManager.playClick();
                                ThemeManager.saveTheme(2);
                              },
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedTheme == 2
                                        ? Colors.orange
                                        : Colors.white,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      "assets/images/homebackground2.png",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
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
            ],
          ),
        );
      },
    );
  }
}
