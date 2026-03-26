import 'package:flutter/material.dart';

class QuestTab extends StatelessWidget {
  final int todaySteps;
  final double todayDistanceKm; final double todayCalories; final double targetCalories;
  final bool q1Claimed; final bool q2Claimed; final bool q3Claimed;
  final Function(int, int, int, int) onRewardClaimed; final VoidCallback onSyncRequested;

  const QuestTab({super.key, required this.todaySteps, required this.todayDistanceKm, required this.todayCalories, required this.targetCalories, required this.q1Claimed, required this.q2Claimed, required this.q3Claimed, required this.onRewardClaimed, required this.onSyncRequested});

  @override
  Widget build(BuildContext context) {
    double displayDistance = double.parse(todayDistanceKm.toStringAsFixed(1));
    int displayCalories = todayCalories.toInt();
    int goalCalories = targetCalories.toInt();

    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DAILY QUESTS', style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                    GestureDetector(
                        onTap: onSyncRequested,
                        child: Row(children: const [Icon(Icons.sync, color: Colors.blueAccent, size: 20), SizedBox(width: 4), Text('동기화', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14))])
                    )
                  ]
              ),
              const SizedBox(height: 24),
              Expanded(
                  child: ListView(
                      children: [
                        _buildDetailedQuestRow(1, Icons.directions_walk, '일일 3000걸음 걷기', todaySteps.toDouble(), 3000.0, 50, 10, 0, todaySteps >= 3000 && !q1Claimed, q1Claimed, isDouble: false),
                        const SizedBox(height: 16),
                        _buildDetailedQuestRow(2, Icons.local_fire_department, '목표 활동 칼로리 소모', displayCalories.toDouble(), goalCalories.toDouble(), 120, 30, 1, displayCalories >= goalCalories && !q2Claimed, q2Claimed, isDouble: false),
                        const SizedBox(height: 16),
                        _buildDetailedQuestRow(3, Icons.directions_run, '누적 3km 달리기', displayDistance, 3.0, 150, 50, 2, displayDistance >= 3.0 && !q3Claimed, q3Claimed, isDouble: true)
                      ]
                  )
              )
            ]
        )
    );
  }

  Widget _buildDetailedQuestRow(int questId, IconData icon, String title, double current, double max, int rewardXp, int rewardGold, int rewardGems, bool canClaim, bool isClaimed, {bool isDouble = false}) {
    bool isCompleted = current >= max; String currentText = isDouble ? current.toString() : current.toInt().toString(); String maxText = isDouble ? max.toString() : max.toInt().toString();
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: isCompleted && !isClaimed ? Colors.amber : Colors.blueGrey.withOpacity(0.3), width: isCompleted && !isClaimed ? 2 : 1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Row(children: [Icon(icon, color: isClaimed ? Colors.grey : (isCompleted ? Colors.greenAccent : Colors.orange), size: 22), const SizedBox(width: 8), Expanded(child: Text(title, style: TextStyle(color: isClaimed ? Colors.grey : (isCompleted ? Colors.greenAccent : Colors.white), fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis))])), Text('($currentText/$maxText)', style: TextStyle(color: isClaimed ? Colors.grey : (isCompleted ? Colors.greenAccent : Colors.amber), fontWeight: FontWeight.bold, fontSize: 14))]), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: (max > 0) ? (current / max).clamp(0.0, 1.0) : 0.0, backgroundColor: Colors.grey[800], color: isClaimed ? Colors.grey : (isCompleted ? Colors.greenAccent : Colors.amber), minHeight: 8)), const SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const Text("보상: ", style: TextStyle(color: Colors.white54, fontSize: 12)), if (rewardXp > 0) Row(children: [const Icon(Icons.star, color: Colors.blueAccent, size: 12), Text(' $rewardXp  ', style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold))]), if (rewardGold > 0) Row(children: [const Icon(Icons.monetization_on, color: Colors.yellow, size: 12), Text(' $rewardGold  ', style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold))]), if (rewardGems > 0) Row(children: [const Icon(Icons.diamond, color: Colors.cyanAccent, size: 12), Text(' $rewardGems', style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold))])]), if (canClaim) ElevatedButton(onPressed: () => onRewardClaimed(questId, rewardXp, rewardGold, rewardGems), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), minimumSize: const Size(60, 30)), child: const Text("보상 받기", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))) else if (isClaimed) const Text("[ 수령 완료 ]", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))])]));
  }
}