import 'package:flutter/material.dart';
import '../widgets/manual_characters_view.dart';

class HomeTab extends StatelessWidget {
  final String selectedCharacter;
  final int gold; final int gems; final int level;
  final double xp; final double maxXp; final double stamina; final double maxStamina;
  final String selectedBg;
  final List<String> equippedFurniture;
  final Function(String) onCharacterChanged;

  const HomeTab({
    super.key, required this.selectedCharacter, required this.gold, required this.gems, required this.level,
    required this.xp, required this.maxXp, required this.stamina, required this.maxStamina,
    required this.selectedBg, required this.equippedFurniture, required this.onCharacterChanged,
  });

  String _getBgAsset(String name) {
    if (name == '헬스장') return 'assets/gym_background.png';
    if (name == '수영장') return 'assets/pool_background.png';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    String currentBgAsset = _getBgAsset(selectedBg);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('KaloMon', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.monetization_on, color: Colors.yellow, size: 16), const SizedBox(width: 4), Text('$gold', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))])),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.diamond, color: Colors.cyanAccent, size: 16), const SizedBox(width: 4), Text('$gems', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: _buildMainStatBar("LV. $level (XP)", xp, maxXp, Colors.blueAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMainStatBar("STAMINA", stamina, maxStamina, Colors.orangeAccent)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSelectButton("캐릭터 1"), const SizedBox(width: 8),
                  _buildSelectButton("캐릭터 2"), const SizedBox(width: 8),
                  _buildSelectButton("character3"),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    image: currentBgAsset.isNotEmpty ? DecorationImage(
                      image: AssetImage(currentBgAsset),
                      fit: BoxFit.fill,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
                    ) : null,
                  ),
                  child: ManualCharacterView(
                    selectedCharacter: selectedCharacter,
                    selectedBg: selectedBg,
                    areaWidth: constraints.maxWidth,
                    areaHeight: constraints.maxHeight,
                    equippedFurniture: equippedFurniture,
                  ),
                );
              }
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatBar(String label, double current, double max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)), Text('${current.toInt()}/${max.toInt()}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11))]),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (max > 0) ? (current / max).clamp(0.0, 1.0) : 0.0, backgroundColor: Colors.white12, color: color, minHeight: 6)),
      ],
    );
  }

  Widget _buildSelectButton(String characterName) {
    bool isSelected = (selectedCharacter == characterName);
    return OutlinedButton(
      onPressed: () => onCharacterChanged(characterName),
      style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.amber.withOpacity(0.2) : Colors.transparent,
          side: BorderSide(color: isSelected ? Colors.amber : Colors.blueGrey.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: Size.zero
      ),
      child: Text(characterName, style: TextStyle(color: isSelected ? Colors.amber : Colors.white70, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    );
  }
}