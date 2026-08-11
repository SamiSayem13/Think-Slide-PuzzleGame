import 'package:flutter/material.dart';

class CongratulationsPage extends StatelessWidget {
  final String time;
  final String moves;
  final VoidCallback? onNextPuzzle;
  final VoidCallback? onHome;

  const CongratulationsPage({
    super.key,
    this.time = "00:00",
    this.moves = "0",
    this.onNextPuzzle,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),

          /// Popup
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 340,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF8EF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.25),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      const _StarRow(),
                      const SizedBox(height: 25),
                      const Text(
                        "Congratulations!",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff6F4E37),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "You solved the puzzle!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.timer_outlined,
                              title: "Time",
                              value: time,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.extension,
                              title: "Moves",
                              value: moves,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      _GameButton(
                        text: "NEXT PUZZLE",
                        color: const Color(0xff5C9442),
                        onPressed: onNextPuzzle ?? () {},
                      ),
                      const SizedBox(height: 15),
                      _GameButton(
                        text: "HOME",
                        color: const Color(0xffD96863),
                        onPressed: onHome ?? () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.star_rounded,
          color: Color(0xffFFC107),
          size: 42,
        ),
        SizedBox(width: 5),
        Icon(
          Icons.star_rounded,
          color: Color(0xffFFC107),
          size: 52,
        ),
        SizedBox(width: 5),
        Icon(
          Icons.star_rounded,
          color: Color(0xffFFC107),
          size: 42,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF4F1EB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xffD89B1D),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff6F4E37),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xffD54C42),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _GameButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<_GameButton> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          scale = 0.94;
        });
      },
      onTapUp: (_) {
        setState(() {
          scale = 1.0;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          scale = 1.0;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: scale,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(.55),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
