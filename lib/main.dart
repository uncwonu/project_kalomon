// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔥 우리가 방금 쪼개놓은 화면 파일들과 '비서(Service)'를 불러옵니다!
import 'screens/home_tab.dart';
import 'screens/quest_tab.dart';
import 'screens/kitchen_page.dart';
import 'screens/profile_tab.dart';
import 'screens/room_decor_tab.dart';
import 'services/health_service.dart'; // 🚀 헬스 전담 비서 호출!

void main() => runApp(const KaloMonApp());

class KaloMonApp extends StatelessWidget {
  const KaloMonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaloMon',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.amberAccent,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  String _selectedCharacter = "character3";

  int _gold = 0;
  int _gems = 0;
  int _level = 1;
  double _xp = 0.0;
  double _maxXp = 500.0;
  double _stamina = 50.0;
  double _maxStamina = 50.0;

  int _todaySteps = 0;
  double _todayDistanceKm = 0.0;
  double _todayCalories = 0.0;

  double _weight = 70.0;
  double _height = 175.0;
  int _age = 23;
  double _muscleMass = 30.0;

  String _selectedBg = '기본';
  List<String> _ownedBgs = ['기본'];
  List<String> _ownedFurniture = [];
  List<String> _equippedFurniture = [];

  String _lastDate = "";
  bool _q1Claimed = false;
  bool _q2Claimed = false;
  bool _q3Claimed = false;

  // 🚀 헬스 전담 비서 객체 생성! (기존 Health 객체 대체)
  final HealthService _healthService = HealthService();

  double get _targetCalories {
    double bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) + 5;
    return bmr * 0.2;
  }

  bool get _hasClaimableQuest {
    bool q1Ready = (_todaySteps >= 3000) && !_q1Claimed;
    bool q2Ready = (_todayCalories >= _targetCalories) && !_q2Claimed;
    bool q3Ready = (_todayDistanceKm >= 3.0) && !_q3Claimed;
    return q1Ready || q2Ready || q3Ready;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedData().then((_) {
      _checkDailyReset();
      _syncHealthData(showSnackbar: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    String todayStr = "${now.year}-${now.month}-${now.day}";

    if (_lastDate != todayStr) {
      setState(() {
        _q1Claimed = false;
        _q2Claimed = false;
        _q3Claimed = false;
        _lastDate = todayStr;
      });
      _saveData();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("KaloMon 복귀 감지. 건강 데이터를 자동 갱신합니다.");
      _checkDailyReset();
      _syncHealthData(showSnackbar: false);
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gold = prefs.getInt('gold') ?? 20000;
      _gems = prefs.getInt('gems') ?? 45;
      _level = prefs.getInt('level') ?? 25;
      _xp = prefs.getDouble('xp') ?? 350.0;
      _stamina = prefs.getDouble('stamina') ?? 40.0;
      _weight = prefs.getDouble('weight') ?? 70.0;
      _height = prefs.getDouble('height') ?? 175.0;
      _age = prefs.getInt('age') ?? 23;
      _muscleMass = prefs.getDouble('muscleMass') ?? 30.0;
      _selectedBg = prefs.getString('selectedBg') ?? '기본';
      _ownedBgs = prefs.getStringList('ownedBgs') ?? ['기본'];
      _ownedFurniture = prefs.getStringList('ownedFurniture') ?? [];
      _equippedFurniture = prefs.getStringList('equippedFurniture') ?? [];
      _q1Claimed = prefs.getBool('q1Claimed') ?? false;
      _q2Claimed = prefs.getBool('q2Claimed') ?? false;
      _q3Claimed = prefs.getBool('q3Claimed') ?? false;
      _lastDate = prefs.getString('lastDate') ?? "";
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gold', _gold);
    await prefs.setInt('gems', _gems);
    await prefs.setInt('level', _level);
    await prefs.setDouble('xp', _xp);
    await prefs.setDouble('stamina', _stamina);
    await prefs.setDouble('weight', _weight);
    await prefs.setDouble('height', _height);
    await prefs.setInt('age', _age);
    await prefs.setDouble('muscleMass', _muscleMass);
    await prefs.setString('selectedBg', _selectedBg);
    await prefs.setStringList('ownedBgs', _ownedBgs);
    await prefs.setStringList('ownedFurniture', _ownedFurniture);
    await prefs.setStringList('equippedFurniture', _equippedFurniture);
    await prefs.setBool('q1Claimed', _q1Claimed);
    await prefs.setBool('q2Claimed', _q2Claimed);
    await prefs.setBool('q3Claimed', _q3Claimed);
    await prefs.setString('lastDate', _lastDate);
  }

  // 🚀 코드가 획기적으로 줄어든 동기화 함수! 비서에게 모든 걸 맡깁니다.
  Future<void> _syncHealthData({bool showSnackbar = true}) async {
    final healthData = await _healthService.fetchTodayHealthData();

    if (healthData != null) {
      setState(() {
        _todaySteps = healthData['steps'] ?? 0;
        _todayDistanceKm = healthData['distanceKm'] ?? 0.0;
        _todayCalories = healthData['calories'] ?? 0.0;
      });

      if (showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('건강 데이터가 성공적으로 동기화되었습니다!')));
      }
    } else {
      if (showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('동기화 실패. 헬스 커넥트를 확인해주세요.')));
      }
    }
  }

  void _claimReward(int questId, int rewardXp, int rewardGold, int rewardGems) {
    setState(() {
      if (questId == 1) _q1Claimed = true;
      if (questId == 2) _q2Claimed = true;
      if (questId == 3) _q3Claimed = true;
      _xp += rewardXp;
      _gold += rewardGold;
      _gems += rewardGems;
      if (_xp >= _maxXp) {
        _level += 1;
        _xp -= _maxXp;
        _stamina = _maxStamina;
      }
    });
    _saveData();
  }

  void _updateProfileData(double w, double h, int a, double m) {
    setState(() { _weight = w; _height = h; _age = a; _muscleMass = m; });
    _saveData();
  }

  void _buyAndApplyBg(String name, int price) {
    if (_ownedBgs.contains(name)) {
      setState(() => _selectedBg = name);
      _saveData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name 배경이 적용되었습니다.')));
    } else {
      if (_gold >= price) {
        setState(() { _gold -= price; _ownedBgs.add(name); _selectedBg = name; });
        _saveData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name 배경을 구매하고 적용했습니다!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('골드가 부족합니다.')));
      }
    }
  }

  void _toggleFurniture(String name, int price) {
    setState(() {
      if (!_ownedFurniture.contains(name)) {
        if (_gold >= price) {
          _gold -= price;
          _ownedFurniture.add(name);
          _equippedFurniture.add(name);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name 구매 및 배치가 완료되었습니다!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('골드가 부족합니다.')));
        }
      } else {
        if (_equippedFurniture.contains(name)) {
          _equippedFurniture.remove(name);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name 배치가 해제되었습니다.')));
        } else {
          _equippedFurniture.add(name);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name 배치가 완료되었습니다!')));
        }
      }
    });
    _saveData();
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return HomeTab(
          selectedCharacter: _selectedCharacter,
          gold: _gold, gems: _gems, level: _level, xp: _xp, maxXp: _maxXp,
          stamina: _stamina, maxStamina: _maxStamina,
          selectedBg: _selectedBg,
          equippedFurniture: _equippedFurniture,
          onCharacterChanged: (newChar) => setState(() => _selectedCharacter = newChar),
        );
      case 1:
        return QuestTab(
          todaySteps: _todaySteps,
          todayDistanceKm: _todayDistanceKm,
          todayCalories: _todayCalories,
          targetCalories: _targetCalories,
          q1Claimed: _q1Claimed, q2Claimed: _q2Claimed, q3Claimed: _q3Claimed,
          onRewardClaimed: _claimReward,
          onSyncRequested: () => _syncHealthData(showSnackbar: true),
        );
      case 2:
        return KitchenPage(selectedCharacter: _selectedCharacter);
      case 3:
        return ProfileTab(
          weight: _weight, height: _height, age: _age, muscleMass: _muscleMass, targetCalories: _targetCalories,
          onProfileUpdated: _updateProfileData,
        );
      case 4:
        return RoomDecorTab(
          gold: _gold, gems: _gems, ownedBgs: _ownedBgs, selectedBg: _selectedBg, onBuyBg: _buyAndApplyBg,
          ownedFurniture: _ownedFurniture,
          equippedFurniture: _equippedFurniture,
          onToggleFurniture: _toggleFurniture,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildCurrentPage()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(
            icon: Badge(isLabelVisible: _hasClaimableQuest, child: const Icon(Icons.assignment)),
            label: 'QUEST',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'KITCHEN'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
          const BottomNavigationBarItem(icon: Icon(Icons.chair), label: 'ROOM'),
        ],
      ),
    );
  }
}