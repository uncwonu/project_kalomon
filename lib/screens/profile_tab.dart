import 'package:flutter/material.dart';

class ProfileTab extends StatefulWidget {
  // 🚀 성별(gender) 변수 추가!
  final String gender;
  final double weight;
  final double height;
  final int age;
  final double muscleMass;
  final double targetCalories;

  // 🚀 콜백 함수에 성별(String)을 쏴주도록 타입 추가!
  final Function(String, double, double, int, double) onProfileUpdated;

  const ProfileTab({
    super.key,
    required this.gender, // 🚀 성별 필수값 지정
    required this.weight,
    required this.height,
    required this.age,
    required this.muscleMass,
    required this.targetCalories,
    required this.onProfileUpdated
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // 🚀 화면에서 선택된 성별을 들고 있을 변수 추가
  late String _currentGender;

  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _muscleCtrl;

  @override
  void initState() {
    super.initState();
    _currentGender = widget.gender; // 🚀 초기 성별 값 세팅
    _weightCtrl = TextEditingController(text: widget.weight.toString());
    _heightCtrl = TextEditingController(text: widget.height.toString());
    _ageCtrl = TextEditingController(text: widget.age.toString());
    _muscleCtrl = TextEditingController(text: widget.muscleMass.toString());
  }

  void _saveProfile() {
    double w = double.tryParse(_weightCtrl.text) ?? widget.weight;
    double h = double.tryParse(_heightCtrl.text) ?? widget.height;
    int a = int.tryParse(_ageCtrl.text) ?? widget.age;
    double m = double.tryParse(_muscleCtrl.text) ?? widget.muscleMass;

    // 🚀 main.dart로 성별을 포함해서 5개의 데이터 쏘기!
    widget.onProfileUpdated(_currentGender, w, h, a, m);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('신체 스탯이 성공적으로 업데이트되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 화면 밖으로 넘치는 걸 방지하기 위해 SingleChildScrollView 추가
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('USER PROFILE', style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 🚀 기존 UI 톤앤매너에 맞춘 성별 선택 버튼 추가!
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('남성', style: TextStyle(fontWeight: FontWeight.bold))),
                    selected: _currentGender == '남성',
                    selectedColor: Colors.amber,
                    backgroundColor: const Color(0xFF0F172A),
                    labelStyle: TextStyle(color: _currentGender == '남성' ? Colors.black : Colors.white54),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide.none,
                    onSelected: (selected) {
                      if (selected) setState(() => _currentGender = '남성');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('여성', style: TextStyle(fontWeight: FontWeight.bold))),
                    selected: _currentGender == '여성',
                    selectedColor: Colors.amber,
                    backgroundColor: const Color(0xFF0F172A),
                    labelStyle: TextStyle(color: _currentGender == '여성' ? Colors.black : Colors.white54),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide.none,
                    onSelected: (selected) {
                      if (selected) setState(() => _currentGender = '여성');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(controller: _ageCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: '나이 (세)', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
            const SizedBox(height: 12),

            TextField(controller: _heightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: '키 (cm)', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
            const SizedBox(height: 12),

            TextField(controller: _weightCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: '몸무게 (kg)', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
            const SizedBox(height: 12),

            TextField(controller: _muscleCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: '근육량 (kg)', labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
            const SizedBox(height: 24),

            ElevatedButton(onPressed: _saveProfile, style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('스탯 저장 및 목표 갱신', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 30),

            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueGrey.withOpacity(0.5))), child: Column(children: [const Text('일일 목표 활동 칼로리', style: TextStyle(color: Colors.white70, fontSize: 14)), const SizedBox(height: 8), Text('${widget.targetCalories.toInt()} kcal', style: const TextStyle(color: Colors.orangeAccent, fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('기초대사량 기반으로 자동 계산된 수치입니다.', style: TextStyle(color: Colors.white54, fontSize: 11))]))
          ]
      ),
    );
  }
}