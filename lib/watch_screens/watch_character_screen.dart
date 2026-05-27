import 'package:flutter/material.dart';
import 'dart:math' as math;

class WatchCharacterScreen extends StatefulWidget {
  const WatchCharacterScreen({super.key});

  @override
  State<WatchCharacterScreen> createState() => _WatchCharacterScreenState();
}

class _WatchCharacterScreenState extends State<WatchCharacterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _idleController;
  final PageController _pageController = PageController();

  final List<String> _bgList = ['기본', '헬스장', '수영장'];
  String _selectedBg = '기본';

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _idleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildBackground() {
    if (_selectedBg == '기본') {
      return Container(color: Colors.black);
    }

    String assetPath = '';
    if (_selectedBg == '헬스장') assetPath = 'assets/gym_background.png';
    if (_selectedBg == '수영장') assetPath = 'assets/pool_background.png';

    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
    );
  }

  // 🚀 터치로 페이지를 넘기는 마법의 함수
  void _goToPage(int pageNum) {
    _pageController.animateToPage(
      pageNum,
      duration: const Duration(milliseconds: 300), // 0.3초 동안 부드럽게
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        // 🚀 [핵심 수정] 워치 시스템 제스처와 충돌하지 않도록 스와이프를 아예 막아버림!
        physics: const NeverScrollableScrollPhysics(),
        children: [

          // ==========================================
          // [페이지 0] 메인 화면
          // ==========================================
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: _buildBackground()),

              AnimatedBuilder(
                animation: _idleController,
                builder: (context, child) {
                  final double yOffset = math.sin(_idleController.value * math.pi * 2) * 4.0;
                  return Transform.translate(offset: Offset(0, yOffset), child: child);
                },
                child: Image.asset(
                  'assets/front.png',
                  width: 120, height: 120, fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.face, color: Colors.white, size: 80),
                ),
              ),

              // 🚀 터치 버튼: 오른쪽 가장자리에 배치
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 28),
                  // 버튼을 누르면 1번 페이지(배경 선택)로 스르륵 이동!
                  onPressed: () => _goToPage(1),
                ),
              ),
            ],
          ),

          // ==========================================
          // [페이지 1] 배경 선택 화면
          // ==========================================
          Stack(
            alignment: Alignment.center,
            children: [
              // 🚀 터치 버튼: 왼쪽 가장자리에 배치 (뒤로 가기)
              Positioned(
                left: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                  // 버튼을 누르면 0번 페이지(메인 화면)로 복귀!
                  onPressed: () => _goToPage(0),
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("배경 선택", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),

                  SizedBox(
                    height: 100,
                    width: 120,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 35,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedBg = _bgList[index];
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _bgList.length,
                        builder: (context, index) {
                          final bool isSelected = _bgList[index] == _selectedBg;
                          return Center(
                            child: Text(
                              _bgList[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontSize: isSelected ? 18 : 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

        ],
      ),
    );
  }
}