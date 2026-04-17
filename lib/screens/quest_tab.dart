import 'package:flutter/material.dart';

class QuestTab extends StatefulWidget {
  final int todaySteps;
  final double todayDistanceKm;
  final double todayCalories;
  final double targetCalories;
  final bool q1Claimed;
  final bool q2Claimed;
  final bool q3Claimed;
  final Function(int, int, int, int) onRewardClaimed; // questId, xp, gold, gems
  final VoidCallback onSyncRequested;

  const QuestTab({
    super.key,
    required this.todaySteps,
    required this.todayDistanceKm,
    required this.todayCalories,
    required this.targetCalories,
    required this.q1Claimed,
    required this.q2Claimed,
    required this.q3Claimed,
    required this.onRewardClaimed,
    required this.onSyncRequested,
  });

  @override
  State<QuestTab> createState() => _QuestTabState();
}

class _QuestTabState extends State<QuestTab> {
  String _selectedTab = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // 🚀 상단 동기화 버튼 영역 (게임 타이틀 느낌)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quest',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1))],
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.onSyncRequested,
                icon: const Icon(Icons.sync, size: 18, color: Colors.white),
                label: const Text('동기화', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          // 🚀 탭 네비게이션 (Normal, Boss, Special)
          Row(
            children: [
              _buildTopTab('Daily', true),
              _buildTopTab('Weekly', false), // 추후 구현
              _buildTopTab('Special', false), // 추후 구현
            ],
          ),

          // 🚀 메인 퀘스트 보드 (스크린샷 느낌의 밝은 회색 컨테이너)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // 밝은 회색 바탕
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border.all(color: Colors.white70, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // 좌측 상단 "Daily MISSION" 텍스트
                      Row(
                        children: [
                          Text(
                            'Daily MISSION',
                            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 🚀 퀘스트 카드 1: 걸음 수
                      _buildQuestCard(
                        questId: 1,
                        title: '일일 3,000걸음 걷기',
                        current: widget.todaySteps.toDouble(),
                        max: 3000.0,
                        rewardXp: 50, rewardGold: 10, rewardGems: 0,
                        isClaimed: widget.q1Claimed,
                      ),

                      // 🚀 퀘스트 카드 2: 칼로리 소모
                      _buildQuestCard(
                        questId: 2,
                        title: '목표 활동 칼로리 소모',
                        current: widget.todayCalories,
                        max: widget.targetCalories > 0 ? widget.targetCalories : 1.0, // 0 나누기 방지
                        rewardXp: 120, rewardGold: 30, rewardGems: 1,
                        isClaimed: widget.q2Claimed,
                        isKcal: true,
                      ),

                      // 🚀 퀘스트 카드 3: 달리기/걷기 거리
                      _buildQuestCard(
                        questId: 3,
                        title: '누적 3.0km 이동하기',
                        current: widget.todayDistanceKm,
                        max: 3.0,
                        rewardXp: 150, rewardGold: 50, rewardGems: 2,
                        isClaimed: widget.q3Claimed,
                        isKm: true,
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

  // 🎯 상단 탭 버튼 빌더
  Widget _buildTopTab(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // 지금은 UI만 보여주고 기능은 Normal 고정
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF64748B),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 퀘스트 카드 빌더
  Widget _buildQuestCard({
    required int questId,
    required String title,
    required double current,
    required double max,
    required int rewardXp,
    required int rewardGold,
    required int rewardGems,
    required bool isClaimed,
    bool isKm = false,
    bool isKcal = false,
  }) {
    bool isReadyToClaim = current >= max && !isClaimed;
    double progressRatio = (current / max).clamp(0.0, 1.0);

    // 카드 테두리 색상 (완료 가능 시 황금색)
    Color borderColor = isReadyToClaim ? Colors.amber : Colors.blueGrey.shade300;
    Color bgColor = isClaimed ? Colors.grey.shade300 : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isReadyToClaim ? 2.0 : 1.5),
        boxShadow: [
          if (isReadyToClaim) BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 6, spreadRadius: 1)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [타이틀 + 보상 뱃지] 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isClaimed ? Colors.grey.shade500 : Colors.blueGrey.shade800,
                    ),
                  ),
                ),
                // 보상 알약(Pill) 뱃지들
                Row(
                  children: [
                    if (rewardXp > 0) _buildRewardPill('EXP', rewardXp.toString(), Colors.blueGrey),
                    const SizedBox(width: 4),
                    if (rewardGold > 0) _buildRewardPill('💰', rewardGold.toString(), Colors.orange),
                    const SizedBox(width: 4),
                    if (rewardGems > 0) _buildRewardPill('💎', rewardGems.toString(), Colors.cyan),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // [현재/목표 수치] 텍스트
            Text(
              '${isKm ? current.toStringAsFixed(2) : isKcal ? current.toStringAsFixed(0) : current.toInt()} / ${isKm ? max.toStringAsFixed(1) : max.toInt()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isClaimed ? Colors.grey.shade400 : Colors.blueGrey.shade400,
              ),
            ),
            const SizedBox(height: 4),

            // [커스텀 프로그레스 바 + 수령 버튼]
            SizedBox(
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // 프로그레스 바 트랙 (배경)
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blueGrey.shade200, width: 1),
                    ),
                  ),
                  // 프로그레스 바 채워짐 (형광 하늘색)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 12,
                        width: constraints.maxWidth * progressRatio,
                        decoration: BoxDecoration(
                          color: isClaimed ? Colors.grey.shade400 : const Color(0xFF00E5FF), // 완료되면 회색
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            if (!isClaimed && progressRatio > 0)
                              BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.5), blurRadius: 4)
                          ],
                        ),
                      );
                    },
                  ),

                  // 완료/수령 버튼 (스크린샷 우측의 동전/인장 느낌)
                  if (isReadyToClaim)
                    Positioned(
                      right: -5,
                      child: GestureDetector(
                        onTap: () => widget.onRewardClaimed(questId, rewardXp, rewardGold, rewardGems),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                    ),

                  // 이미 수령 완료된 상태 표시
                  if (isClaimed)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
                        child: const Text('CLEAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 우측 상단 보상 표시용 작은 뱃지
  Widget _buildRewardPill(String label, String value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade400,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade600, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }
}