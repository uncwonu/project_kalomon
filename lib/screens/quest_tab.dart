import 'package:flutter/material.dart';

class QuestTab extends StatefulWidget {
  final int todaySteps;
  final double todayDistanceKm;
  final double todayCalories;
  final double targetCalories;
  final bool q1Claimed;
  final bool q2Claimed;
  final bool q3Claimed;

  final int currentStreak;
  final int longestStreak;
  final int streakFreezeCount;
  final int completedDailyQuests;
  final bool canClaimDailyChest;
  final bool dailyChestClaimed;

  final Function(int, int, int, int) onRewardClaimed;
  final VoidCallback onSyncRequested;
  final VoidCallback onDailyChestClaimed;

  const QuestTab({
    super.key,
    required this.todaySteps,
    required this.todayDistanceKm,
    required this.todayCalories,
    required this.targetCalories,
    required this.q1Claimed,
    required this.q2Claimed,
    required this.q3Claimed,
    required this.currentStreak,
    required this.longestStreak,
    required this.streakFreezeCount,
    required this.completedDailyQuests,
    required this.canClaimDailyChest,
    required this.dailyChestClaimed,
    required this.onRewardClaimed,
    required this.onSyncRequested,
    required this.onDailyChestClaimed,
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
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRetentionPanel(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTopTab('Daily', _selectedTab == 'Daily'),
              _buildTopTab('Weekly', _selectedTab == 'Weekly'),
              _buildTopTab('Special', _selectedTab == 'Special'),
            ],
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
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
                      Row(
                        children: [
                          Text(
                            _selectedTab == 'Daily'
                                ? 'Daily MISSION'
                                : _selectedTab == 'Weekly'
                                ? 'Weekly MISSION'
                                : 'Special MISSION',
                            style: TextStyle(
                              color: Colors.blueGrey.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_selectedTab == 'Daily') ...[
                        _buildQuestCard(
                          questId: 1,
                          title: '일일 3,000걸음 걷기',
                          current: widget.todaySteps.toDouble(),
                          max: 3000.0,
                          rewardXp: 50,
                          rewardGold: 10,
                          rewardGems: 0,
                          isClaimed: widget.q1Claimed,
                        ),
                        _buildQuestCard(
                          questId: 2,
                          title: '목표 활동 칼로리 소모',
                          current: widget.todayCalories,
                          max: widget.targetCalories > 0 ? widget.targetCalories : 1.0,
                          rewardXp: 120,
                          rewardGold: 30,
                          rewardGems: 1,
                          isClaimed: widget.q2Claimed,
                          isKcal: true,
                        ),
                        _buildQuestCard(
                          questId: 3,
                          title: '누적 3.0km 이동하기',
                          current: widget.todayDistanceKm,
                          max: 3.0,
                          rewardXp: 150,
                          rewardGold: 50,
                          rewardGems: 2,
                          isClaimed: widget.q3Claimed,
                          isKm: true,
                        ),
                      ] else
                        _buildComingSoonPanel(),
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

  Widget _buildRetentionPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.deepOrangeAccent.withOpacity(0.35)),
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.deepOrangeAccent, size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kalo Streak ${widget.currentStreak}일',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daily Quest ${widget.completedDailyQuests}/3 완료',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (widget.completedDailyQuests / 3).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.shield, size: 14, color: Colors.cyanAccent),
                  const SizedBox(width: 3),
                  Text(
                    '${widget.streakFreezeCount}',
                    style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: widget.canClaimDailyChest ? widget.onDailyChestClaimed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  disabledBackgroundColor: Colors.white12,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  minimumSize: const Size(72, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  widget.dailyChestClaimed ? '수령완료' : 'Chest',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.dailyChestClaimed ? Colors.white54 : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopTab(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = text);
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

  Widget _buildComingSoonPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_clock, color: Colors.blueGrey.shade300, size: 40),
          const SizedBox(height: 10),
          Text(
            '곧 열릴 예정입니다',
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Daily Quest를 먼저 완료해보세요.',
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

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

    Color borderColor = isReadyToClaim ? Colors.amber : Colors.blueGrey.shade300;
    Color bgColor = isClaimed ? Colors.grey.shade300 : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isReadyToClaim ? 2.0 : 1.5),
        boxShadow: [
          if (isReadyToClaim) BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 6, spreadRadius: 1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                Row(
                  children: [
                    if (rewardXp > 0) _buildRewardPill('EXP', rewardXp.toString(), Colors.blueGrey),
                    const SizedBox(width: 4),
                    if (rewardGold > 0) _buildRewardPill('G', rewardGold.toString(), Colors.orange),
                    const SizedBox(width: 4),
                    if (rewardGems > 0) _buildRewardPill('Gem', rewardGems.toString(), Colors.cyan),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${isKm ? current.toStringAsFixed(2) : isKcal ? current.toStringAsFixed(0) : current.toInt()} / ${isKm ? max.toStringAsFixed(1) : max.toInt()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isClaimed ? Colors.grey.shade400 : Colors.blueGrey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blueGrey.shade200, width: 1),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 12,
                        width: constraints.maxWidth * progressRatio,
                        decoration: BoxDecoration(
                          color: isClaimed ? Colors.grey.shade400 : const Color(0xFF00E5FF),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            if (!isClaimed && progressRatio > 0)
                              BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.5), blurRadius: 4),
                          ],
                        ),
                      );
                    },
                  ),
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
                  if (isClaimed)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
                        child: const Text(
                          'CLEAR',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
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