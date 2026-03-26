import 'package:flutter/material.dart';
import 'dart:async';

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

class _ManualCharacterViewState extends State<ManualCharacterView> {
  Timer? _moveTimer;

  double _x = 150.0;
  double _y = 300.0;
  int _direction = 2;
  int _step = 0;
  int _tickCount = 0;
  final double _speed = 4.0;

  final int _cols = 20;
  final int _rows = 32;
  List<List<Tile>> _gridMap = [];

  final double charWidth = 80.0;
  final double charHeight = 160.0;

  final Map<String, Map<String, dynamic>> gymFurnitureSpecs = {
    '파워 랙': { 'asset': 'assets/power_rack.png', 'l': 0.02, 't': 0.025, 'w': 0.43, 'hitX': [1,2,3,4,5,6,7], 'hitY': [8,9,10,11,12,13] },
    '케이블 머신': { 'asset': 'assets/cable.png', 'l': 0.55, 't': 0.06, 'w': 0.45, 'hitX': [11,12,13,14,15,16,17,18], 'hitY': [8,9,10,11,12,13] },
    '런닝머신': { 'asset': 'assets/treadmill.png', 'l': -0.07, 't': 0.65, 'w': 0.60, 'hitX': [1,2,3,4,5,6,7], 'hitY': [28,29,30] },
    '덤벨 세트': { 'asset': 'assets/dumbel.png', 'l': 0.197, 't': 0.33, 'w': 0.8, 'hitX': [11,12,13,14,15,16,17,18], 'hitY': [25,26,27,28,29,30] },
    '동기부여 포스터': { 'asset': 'assets/poster.png', 'l': 0.45, 't': 0.03, 'w': 0.14, 'hitX': [], 'hitY': [] },
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
    _generateGridMap();
    _resetPosition();
  }

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
      _y = widget.areaHeight / 2;
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
    double feetY = ny + charHeight - 20;

    int gridX = (feetX / tileW).floor();
    int gridY = (feetY / tileH).floor();

    if (gridX < 0 || gridX >= _cols || gridY < 0 || gridY >= _rows) return false;

    Tile targetTile = _gridMap[gridY][gridX];
    if (targetTile.type == TileType.wall) return false;
    if (targetTile.type == TileType.water) return false;
    if (targetTile.isOccupied) return false;

    return true;
  }

  void _startMoving(int dir) {
    _direction = dir;
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
        if (_tickCount >= 8) { _step = 1 - _step; _tickCount = 0; }
      });
    });
  }

  void _stopMoving() {
    _moveTimer?.cancel();
    setState(() { _step = 0; });
  }

  String _getCurrentSprite() {
    if (widget.selectedCharacter != "character3") {
      if (widget.selectedCharacter == "캐릭터 1") return 'assets/1772771310720.png';
      if (widget.selectedCharacter == "캐릭터 2") return 'assets/1772771352804.png';
      return 'assets/placeholder.png';
    }
    if (_direction == 0) return _step == 0 ? 'assets/오뒤.png' : 'assets/왼뒤.png';
    if (_direction == 1) return _step == 0 ? 'assets/오2.png' : 'assets/오3.png';
    if (_direction == 2) return _step == 0 ? 'assets/오앞.png' : 'assets/왼앞.png';
    if (_direction == 3) return _step == 0 ? 'assets/왼2.PNG' : 'assets/왼3.PNG';
    return 'assets/오앞.png';
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
  void dispose() { _moveTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    double tileW = widget.areaWidth / _cols;
    double tileH = widget.areaHeight / _rows;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Column(
              children: List.generate(_rows, (r) => Container(
                height: tileH,
                child: Row(
                  children: List.generate(_cols, (c) {
                    return Container(width: tileW, decoration: const BoxDecoration(color: Colors.transparent));
                  }),
                ),
              )),
            ),
          ),
        ),

        if (widget.selectedBg == '헬스장')
          ...widget.equippedFurniture.where((name) => gymFurnitureSpecs.containsKey(name)).map((name) {
            final spec = gymFurnitureSpecs[name]!;
            return Positioned(
              left: widget.areaWidth * spec['l'],
              top: widget.areaHeight * spec['t'],
              width: widget.areaWidth * spec['w'],
              child: Image.asset(spec['asset'], fit: BoxFit.contain),
            );
          }),

        if (widget.selectedBg == '수영장')
          ...widget.equippedFurniture.where((name) => poolFurnitureSpecs.containsKey(name)).map((name) {
            final spec = poolFurnitureSpecs[name]!;
            return Positioned(
              left: widget.areaWidth * spec['l'],
              top: widget.areaHeight * spec['t'],
              width: widget.areaWidth * spec['w'],
              child: Image.asset(spec['asset'], fit: BoxFit.contain),
            );
          }),

        Positioned(
          left: _x, top: _y,
          child: Transform.scale(
            scale: 0.8,
            child: Image.asset(_getCurrentSprite(), fit: BoxFit.contain, height: charHeight, errorBuilder: (context, error, stackTrace) => const SizedBox.shrink()),
          ),
        ),

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