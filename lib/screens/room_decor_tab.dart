import 'package:flutter/material.dart';

class RoomDecorTab extends StatefulWidget {
  final int gold; final int gems; final List<String> ownedBgs; final String selectedBg; final Function(String, int) onBuyBg;
  final List<String> ownedFurniture;
  final List<String> equippedFurniture;
  final Function(String, int) onToggleFurniture;

  const RoomDecorTab({super.key, required this.gold, required this.gems, required this.ownedBgs, required this.selectedBg, required this.onBuyBg, required this.ownedFurniture, required this.equippedFurniture, required this.onToggleFurniture});

  @override
  State<RoomDecorTab> createState() => _RoomDecorTabState();
}

class _RoomDecorTabState extends State<RoomDecorTab> {
  String _interiorCategory = '기본 가구';

  Widget _buildItemCard({IconData? icon, String? imagePath, required String name, required int price}) {
    bool isOwned = widget.ownedFurniture.contains(name);
    bool isEquipped = widget.equippedFurniture.contains(name);

    return Container(
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: isEquipped ? Colors.greenAccent : (isOwned ? Colors.amber : Colors.blueGrey.withOpacity(0.5)), width: isEquipped || isOwned ? 2 : 1)),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset('assets/$imagePath', height: 45, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white54, size: 30))
            else if (icon != null)
              Icon(icon, size: 40, color: Colors.white70),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.monetization_on, color: Colors.yellow, size: 12), const SizedBox(width: 4), Text('$price', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12))]),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => widget.onToggleFurniture(name, price),
              style: ElevatedButton.styleFrom(
                backgroundColor: isEquipped ? Colors.redAccent.withOpacity(0.8) : (isOwned ? Colors.blueAccent : Colors.amber),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: const Size(60, 26),
              ),
              child: Text(isEquipped ? '배치 해제' : (isOwned ? '배치하기' : '구매하기'), style: TextStyle(color: isEquipped || isOwned ? Colors.white : Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          ]
      ),
    );
  }

  Widget _buildBgCard(String name, int price, String assetPath) {
    bool isOwned = widget.ownedBgs.contains(name); bool isSelected = widget.selectedBg == name;
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? Colors.amber : Colors.blueGrey.withOpacity(0.5), width: isSelected ? 2 : 1), image: assetPath.isNotEmpty ? DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken)) : null),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 8),
          if (!isOwned) Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.monetization_on, color: Colors.yellow, size: 14), const SizedBox(width: 4), Text('$price', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))]), const SizedBox(height: 12),
          ElevatedButton(onPressed: isSelected ? null : () => widget.onBuyBg(name, price), style: ElevatedButton.styleFrom(backgroundColor: isSelected ? Colors.grey : (isOwned ? Colors.blueAccent : Colors.amber), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), minimumSize: const Size(60, 30)), child: Text(isSelected ? '적용됨' : (isOwned ? '적용하기' : '구매하기'), style: TextStyle(color: isSelected ? Colors.white54 : (isOwned ? Colors.white : Colors.black), fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('STYLE SHOP', style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.monetization_on, color: Colors.yellow, size: 16), const SizedBox(width: 4), Text('${widget.gold}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]))]),
              ],
            ),
            const SizedBox(height: 20),
            const TabBar(indicatorColor: Colors.amber, labelColor: Colors.amber, unselectedLabelColor: Colors.white54, tabs: [Tab(icon: Icon(Icons.chair), text: "인테리어"), Tab(icon: Icon(Icons.checkroom), text: "의상"), Tab(icon: Icon(Icons.wallpaper), text: "배경")]),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(label: const Text('기본 가구'), selected: _interiorCategory == '기본 가구', onSelected: (val) => setState(() => _interiorCategory = '기본 가구'), selectedColor: Colors.amber.withOpacity(0.3), backgroundColor: Colors.transparent), const SizedBox(width: 8),
                            ChoiceChip(label: const Text('💪 헬스장'), selected: _interiorCategory == '헬스장 인테리어', onSelected: (val) => setState(() => _interiorCategory = '헬스장 인테리어'), selectedColor: Colors.amber.withOpacity(0.3), backgroundColor: Colors.transparent), const SizedBox(width: 8),
                            ChoiceChip(label: const Text('🏊 수영장'), selected: _interiorCategory == '수영장 인테리어', onSelected: (val) => setState(() => _interiorCategory = '수영장 인테리어'), selectedColor: Colors.amber.withOpacity(0.3), backgroundColor: Colors.transparent),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                          child: _interiorCategory == '기본 가구'
                              ? const Center(child: Text("기본 가구 에셋이 비어있습니다.", style: TextStyle(color: Colors.white54)))
                              : _interiorCategory == '헬스장 인테리어'
                              ? GridView.count(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, children: [
                            _buildItemCard(imagePath: 'power_rack.png', name: '파워 랙', price: 1500),
                            _buildItemCard(imagePath: 'treadmill.png', name: '런닝머신', price: 1200),
                            _buildItemCard(imagePath: 'cable.png', name: '케이블 머신', price: 1800),
                            _buildItemCard(imagePath: 'dumbel.png', name: '덤벨 세트', price: 500),
                            _buildItemCard(imagePath: 'poster.png', name: '동기부여 포스터', price: 200)
                          ])
                              : GridView.count(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, children: [
                            _buildItemCard(imagePath: 'safety.png', name: '안전 수칙', price: 100),
                            _buildItemCard(imagePath: 'caution.png', name: '경고 표지판', price: 100),
                            _buildItemCard(imagePath: 'emergency_kit.png', name: '응급 처치함', price: 300),
                            _buildItemCard(imagePath: 'tube.png', name: '구명 튜브', price: 500),
                            _buildItemCard(imagePath: 'fin.png', name: '오리발 보관함', price: 800),
                            _buildItemCard(imagePath: 'equipment.png', name: '수영 장비장', price: 1000)
                          ])
                      ),
                    ],
                  ),
                  GridView.count(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, children: [_buildItemCard(icon: Icons.directions_run, name: '스포티 러닝복', price: 400), _buildItemCard(icon: Icons.accessibility_new, name: '캐주얼 후디', price: 250), _buildItemCard(icon: Icons.business_center, name: '모던 정장', price: 900), _buildItemCard(icon: Icons.snowshoeing, name: '고어텍스 등산복', price: 600), _buildItemCard(icon: Icons.face, name: '쿨 선글라스', price: 150), _buildItemCard(icon: Icons.watch, name: '스마트 워치', price: 700)]),
                  GridView.count(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, children: [_buildBgCard('헬스장', 1500, 'assets/gym_background.png'), _buildBgCard('수영장', 2000, 'assets/pool_background.png'), _buildBgCard('기본', 0, '')]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}