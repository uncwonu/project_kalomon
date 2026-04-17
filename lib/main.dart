// lib/main.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

import 'screens/home_tab.dart';
import 'screens/quest_tab.dart';
import 'screens/kitchen_page.dart';
import 'screens/profile_tab.dart';
import 'screens/room_decor_tab.dart';
import 'services/health_service.dart';

// 🚀 워치용 화면 임포트 추가!
import 'watch_screens/watch_character_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const KaloMonApp());
}

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
      // 🚀 [해결 완료] 로그인 체크보다 '화면 크기 체크'를 먼저 합니다!
      home: LayoutBuilder(
        builder: (context, constraints) {
          // ⌚ 1. 워치 판별 (로그인 과정을 쿨하게 패스하고 바로 캐릭터 노출!)
          if (constraints.maxWidth < 300) {
            return const WatchCharacterScreen();
          }
          // 📱 2. 스마트폰 판별 (기존처럼 Firebase 로그인 체크 진행)
          else {
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Color(0xFF1E293B),
                    body: Center(child: CircularProgressIndicator(color: Colors.amber)),
                  );
                }
                if (snapshot.hasData) {
                  return const MainScreen(); // 로그인 되어있으면 메인
                }
                return const login_screen(); // 안 되어있으면 폰에서만 로그인 화면 노출
              },
            );
          }
        },
      ),
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
  double _todayCalories = 0.0; // 화면에 보여줄 '진짜' 활동 소모 칼로리

  // 🚀 성별 데이터 추가! (기본값: 남성)
  String _gender = "남성";
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

  final HealthService _healthService = HealthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🚀 성별을 고려한 정밀 BMR 계산 및 목표 칼로리 설정
  double get _targetCalories {
    double bmr;
    if (_gender == "남성") {
      bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) + 5;
    } else {
      bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) - 161;
    }
    return bmr * 0.2; // 기초대사량의 20%를 목표 활동량으로!
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

  Future<void> _loadSavedData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _gold = data['gold'] ?? 20000;
          _gems = data['gems'] ?? 45;
          _level = data['level'] ?? 25;
          _xp = (data['xp'] ?? 350.0).toDouble();
          _stamina = (data['stamina'] ?? 40.0).toDouble();

          // 🚀 클라우드에서 성별 데이터 불러오기
          _gender = data['gender'] ?? "남성";
          _weight = (data['weight'] ?? 70.0).toDouble();
          _height = (data['height'] ?? 175.0).toDouble();
          _age = data['age'] ?? 23;
          _muscleMass = (data['muscleMass'] ?? 30.0).toDouble();

          _selectedBg = data['selectedBg'] ?? '기본';
          _ownedBgs = List<String>.from(data['ownedBgs'] ?? ['기본']);
          _ownedFurniture = List<String>.from(data['ownedFurniture'] ?? []);
          _equippedFurniture = List<String>.from(data['equippedFurniture'] ?? []);
          _q1Claimed = data['q1Claimed'] ?? false;
          _q2Claimed = data['q2Claimed'] ?? false;
          _q3Claimed = data['q3Claimed'] ?? false;
          _lastDate = data['lastDate'] ?? "";
        });
      } else {
        _saveData();
      }
    } catch (e) {
      debugPrint("클라우드 데이터 불러오기 에러: $e");
    }
  }

  Future<void> _saveData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'gold': _gold,
        'gems': _gems,
        'level': _level,
        'xp': _xp,
        'stamina': _stamina,
        'gender': _gender, // 🚀 클라우드에 성별 저장
        'weight': _weight,
        'height': _height,
        'age': _age,
        'muscleMass': _muscleMass,
        'selectedBg': _selectedBg,
        'ownedBgs': _ownedBgs,
        'ownedFurniture': _ownedFurniture,
        'equippedFurniture': _equippedFurniture,
        'q1Claimed': _q1Claimed,
        'q2Claimed': _q2Claimed,
        'q3Claimed': _q3Claimed,
        'lastDate': _lastDate,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("클라우드 데이터 저장 에러: $e");
    }
  }

  // 🚀 대망의 헬스 데이터 동기화 및 칼로리 정밀 계산 로직!
  Future<void> _syncHealthData({bool showSnackbar = true}) async {
    final healthData = await _healthService.fetchTodayHealthData();

    if (healthData != null) {
      setState(() {
        _todaySteps = healthData['steps']?.toInt() ?? 0;
        _todayDistanceKm = healthData['distanceKm'] ?? 0.0;

        // 1. 서비스에서 삼성이 준 활동 칼로리와 총 소모 칼로리 둘 다 가져오기
        double samsungActiveCalories = healthData['calories'] ?? 0.0;
        double fetchedTotalCalories = healthData['totalCalories'] ?? 0.0;

        // 2. 성별에 따른 하루 전체 기초대사량(BMR) 계산 (Mifflin-St Jeor 공식)
        double bmr;
        if (_gender == "남성") {
          bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) + 5;
        } else {
          bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) - 161;
        }

        // 3. 자정부터 현재 시간까지 흘러간 시간에 비례한 기초대사량 계산
        final now = DateTime.now();
        double minutesPassed = (now.hour * 60) + now.minute.toDouble();
        double bmrUpToNow = bmr * (minutesPassed / 1440.0); // 1440분 = 24시간

        // 4. 우리가 직접 계산한 진짜 활동 칼로리!
        double calculatedActiveCalories = fetchedTotalCalories - bmrUpToNow;
        if (calculatedActiveCalories < 0) calculatedActiveCalories = 0.0; // 음수 방지

        // 5. 철통 보안: 우리가 계산한 값과 삼성이 준 활동 칼로리 중 더 '큰 값'을 사용!
        _todayCalories = calculatedActiveCalories > samsungActiveCalories
            ? calculatedActiveCalories
            : samsungActiveCalories;
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

  // 🚀 ProfileTab에서 성별을 포함해 데이터를 넘겨줄 때 받는 함수
  void _updateProfileData(String g, double w, double h, int a, double m) {
    setState(() { _gender = g; _weight = w; _height = h; _age = a; _muscleMass = m; });
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
          gender: _gender, // 🚀 ProfileTab에 성별 데이터 넘겨주기
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