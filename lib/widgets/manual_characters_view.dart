import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math; // 🚀 숨쉬기 계산을 위한 수학 라이브러리

enum TileType { wall, floor, water }

class Tile {
  TileType type;
  bool isOccupied;
  Tile({required this.type, this.isOccupied = false});
}

class ManualCharacterView extends StatefulWidget {
  final String selectedCharacter;
  final String selectedBg;
  final double areaWidth;
  final double areaHeight;
  final List<String> equippedFurniture;

  const ManualCharacterView({
    super.key,
    required this.selectedCharacter,
    required this.selectedBg,
    required this.areaWidth,
    required this.areaHeight,
    required this.equippedFurniture,
  });

  @override
  State<ManualCharacterView> createState() => _ManualCharacterViewState();
}

// 🚀 애니메이션 사용을 위해 SingleTickerProviderStateMixin 추가
class _ManualCharacterViewState extends State<ManualCharacterView> with SingleTickerProviderStateMixin {
  Timer? _moveTimer;
  late AnimationController _idleController; // 🚀 숨쉬기용 컨트롤러

  double _x = 150.0;
  double _y = 300.0;
  int _direction = 2; // 0: 위, 1: 오른쪽, 2: 아래, 3: 왼쪽

  int _walkFrame = 0;
  int _tickCount = 0;
  final double _speed = 4.0;
  bool _isMoving = false; // 🚀 현재 이동 중인지 확인하는 플래그

  final int _cols = 20;
  final int _rows = 32;
  List<List<Tile>> _gridMap = [];

  final double charWidth = 120.0;
  final double charHeight = 120.0;

  // 가구 Specs (기존과 동일)
  final Map<String, Map<String, dynamic>> gymFurnitureSpecs = {
    '파워 랙': { 'asset': 'assets/power_rack.png', 'l': -0.12, 't': -0.1, 'w': 0.7, 'hitX': [1,2,3,4,5,6,7], 'hitY': [8,9,10,11,12,13] },
    '케이블 머신': { 'asset': 'assets/cable.png', 'l': 0.55, 't': 0.06, 'w': 0.45, 'hitX': [11,12,13,14,15,16,17,18], 'hitY': [8,9,10,11,12,13] },
    '런닝머신': { 'asset': 'assets/treadmill.png', 'l': -0.07, 't': 0.65, 'w': 0.60, 'hitX': [1,2,3,4,5,6,7], 'hitY': [28,29,30] },
    '덤벨 세트': { 'asset': 'assets/dumbel.png', 'l': 0.197, 't': 0.33, 'w': 0.8, 'hitX': [11,12,13,14,15,16,17,18], 'hitY': [25,26,27,28,29,30] },
    '동기부여 포스터': { 'asset': 'assets/poster.png', 'l': 0.43, 't': 0.03, 'w': 0.14, 'hitX': [], 'hitY': [] },
  };

  final Map<String, Map<String, dynamic>> poolFurnitureSpecs = {
    '안전 수칙': { 'asset': 'assets/safety.png', 'l': 0.75, 't': 0.01, 'w': 0.15, 'hitX': [], 'hitY': [] },
    '경고 표지판': { 'asset': 'assets/caution.png', 'l': 0.003, 't': 0.06, 'w': 0.09, 'hitX': [], 'hitY': [] },
    '응급 처치함': { 'asset': 'assets/emergency_kit.png', 'l': 0.13, 't': 0.015, 'w': 0.5, 'hitX': [], 'hitY': [] },
    '구명 튜브': { 'asset': 'assets/tube.png', 'l': 0.27, 't': 0.15, 'w': 0.4, 'hitX': [], 'hitY': [] },
    '오리발 보관함': { 'asset': 'assets/fin.png', 'l': -0.02, 't': 0.83, 'w': 0.35, 'hitX': [0,1,2,3,4,5], 'hitY': [27,28, 29,30,31] },
    '수영 장비장': { 'asset': 'assets/equipment.png', 'l': 0.65, 't': 0.157, 'w': 0.35, 'hitX': [11,12,13,14,15,16,17,18,19], 'hitY': [1,2,3,4,5,6,7,8,9,10,11] },
  };

  @override
  void initState() {
    super.initState();
    // 🚀 숨쉬기 애니메이션 설정 (1.5초 주기로 부드럽게 반복)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _generateGridMap();
    _resetPosition();
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _idleController.dispose(); // 🚀 컨트롤러 해제 필수
    super.dispose();
  }

  // ... (didUpdateWidget, _resetPosition, _generateGridMap, _canMoveTo 로직 동일) ...
  @override
  void didUpdateWidget(ManualCharacterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedBg != oldWidget.selectedBg || widget.equippedFurniture.length != oldWidget.equippedFurniture.length) {
      _generateGridMap();
      if (widget.selectedBg != oldWidget.selectedBg) _resetPosition();
    }
  }

  void _resetPosition() {
    setState(() {
      _x = widget.areaWidth / 2 - (charWidth / 2);
      _y = widget.areaHeight / 2 - (charHeight / 2);
      _direction = 2;
    });
  }

  void _generateGridMap() {
    _gridMap = List.generate(_rows, (r) {
      return List.generate(_cols, (c) {
        TileType type = TileType.floor;
        if (widget.selectedBg == '헬스장') { if (r < 10) type = TileType.wall; }
        else if (widget.selectedBg == '수영장') {
          if (r < 10) type = TileType.wall;
          if (c >=10 && r >= 13 && r < 28) type = TileType.water;
        }
        else { if (r < 4) type = TileType.wall; }
        return Tile(type: type);
      });
    });

    Map<String, Map<String, dynamic>> targetSpecs = {};
    if (widget.selectedBg == '헬스장') targetSpecs = gymFurnitureSpecs;
    else if (widget.selectedBg == '수영장') targetSpecs = poolFurnitureSpecs;

    for (String name in widget.equippedFurniture) {
      if (targetSpecs.containsKey(name)) {
        List<int> hitX = List<int>.from(targetSpecs[name]!['hitX']);
        List<int> hitY = List<int>.from(targetSpecs[name]!['hitY']);
        for (int x in hitX) {
          for (int y in hitY) {
            if (y < _rows && x < _cols) _gridMap[y][x].isOccupied = true;
          }
        }
      }
    }
  }

  bool _canMoveTo(double nx, double ny) {
    double tileW = widget.areaWidth / _cols;
    double tileH = widget.areaHeight / _rows;
    double feetX = nx + (charWidth / 2);
    double feetY = ny + charHeight - 15;
    int gridX = (feetX / tileW).floor();
    int gridY = (feetY / tileH).floor();
    if (gridX < 0 || gridX >= _cols || gridY < 0 || gridY >= _rows) return false;
    Tile targetTile = _gridMap[gridY][gridX];
    if (targetTile.type == TileType.wall || targetTile.type == TileType.water || targetTile.isOccupied) return false;
    return true;
  }

  void _startMoving(int dir) {
    _direction = dir;
    _isMoving = true; // 🚀 이동 상태로 변경
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        double nx = _x; double ny = _y;
        if (_direction == 1) nx += _speed;
        else if (_direction == 2) ny += _speed;
        else if (_direction == 3) nx -= _speed;
        else if (_direction == 0) ny -= _speed;

        nx = nx.clamp(0.0, widget.areaWidth - charWidth);
        ny = ny.clamp(0.0, widget.areaHeight - charHeight);

        if (_canMoveTo(nx, ny)) { _x = nx; _y = ny; }

        _tickCount++;
        if (_tickCount >= 8) {
          _walkFrame = (_walkFrame + 1) % 4;
          _tickCount = 0;
        }
      });
    });
  }

  void _stopMoving() {
    _moveTimer?.cancel();
    setState(() {
      _walkFrame = 0;
      _isMoving = false; // 🚀 정지 상태로 변경
    });
  }

  String _getBaseSprite() {
    String dirStr;
    switch (_direction) {
      case 0: dirStr = 'back'; break;
      case 1: dirStr = 'right'; break;
      case 2: dirStr = 'front'; break;
      case 3: dirStr = 'left'; break;
      default: dirStr = 'front';
    }
    if (_walkFrame == 0 || _walkFrame == 2) return 'assets/$dirStr.png';
    else if (_walkFrame == 1) return 'assets/${dirStr}_left.png';
    else return 'assets/${dirStr}_right.png';
  }

  Widget _buildDirBtn(IconData icon, int dir) {
    return GestureDetector(
      onTapDown: (_) => _startMoving(dir),
      onTapUp: (_) => _stopMoving(),
      onTapCancel: () => _stopMoving(),
      child: Container(
        width: 55, height: 55,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle, border: Border.all(color: Colors.amber.withOpacity(0.7), width: 2)),
        child: Icon(icon, color: Colors.amber, size: 35),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double tileW = widget.areaWidth / _cols;
    double tileH = widget.areaHeight / _rows;

    return Stack(
      children: [
        // 배경 그리드 및 가구 렌더링 (기존과 동일)
        Positioned.fill(
          child: IgnorePointer(
            child: Column(
              children: List.generate(_rows, (r) => Container(
                height: tileH,
                child: Row(
                  children: List.generate(_cols, (c) => Container(width: tileW, decoration: const BoxDecoration(color: Colors.transparent))),
                ),
              )),
            ),
          ),
        ),

        if (widget.selectedBg == '헬스장')
          ...widget.equippedFurniture.where((name) => gymFurnitureSpecs.containsKey(name)).map((name) {
            final spec = gymFurnitureSpecs[name]!;
            return Positioned(left: widget.areaWidth * spec['l'], top: widget.areaHeight * spec['t'], width: widget.areaWidth * spec['w'], child: Image.asset(spec['asset'], fit: BoxFit.contain));
          }),

        if (widget.selectedBg == '수영장')
          ...widget.equippedFurniture.where((name) => poolFurnitureSpecs.containsKey(name)).map((name) {
            final spec = poolFurnitureSpecs[name]!;
            return Positioned(left: widget.areaWidth * spec['l'], top: widget.areaHeight * spec['t'], width: widget.areaWidth * spec['w'], child: Image.asset(spec['asset'], fit: BoxFit.contain));
          }),

        // 🚀 [캐릭터 렌더링 + AnimatedBuilder 적용]
        Positioned(
          left: _x, top: _y,
          child: SizedBox(
            width: charWidth,
            height: charHeight,
            child: AnimatedBuilder(
              animation: _idleController,
              builder: (context, child) {
                // 🚀 대표님이 좋아하신 '부드러운 둥실거림' 계산
                final double angle = _idleController.value * math.pi * 2;
                // 🚀 이동 중일 땐 바운스를 최소화(1), 멈춰있을 땐 좀 더 부드럽게(4~5 추천) 조절 가능합니다.
                final double yOffset = math.sin(angle) * (1.0);

                return Transform.translate(
                  offset: Offset(0, yOffset),
                  child: child,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    _getBaseSprite(),
                    width: charWidth,
                    height: charHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                  // 여기에 2층(옷), 3층(머리) 추가 예정
                ],
              ),
            ),
          ),
        ),

        // 조이스틱 버튼
        Positioned(
          bottom: 30, right: 20,
          child: Column(
            children: [
              _buildDirBtn(Icons.keyboard_arrow_up, 0), const SizedBox(height: 6),
              Row(children: [_buildDirBtn(Icons.keyboard_arrow_left, 3), const SizedBox(width: 60), _buildDirBtn(Icons.keyboard_arrow_right, 1)]),
              const SizedBox(height: 6), _buildDirBtn(Icons.keyboard_arrow_down, 2),
            ],
          ),
        )
      ],
    );
  }
}