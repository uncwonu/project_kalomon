// lib/services/health_service.dart

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class HealthService {
  final Health _health = Health();

  Future<Map<String, dynamic>?> fetchTodayHealthData() async {
    await Permission.activityRecognition.request();

    var types = [
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_DELTA,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.TOTAL_CALORIES_BURNED,
      HealthDataType.WORKOUT,
    ];

    var permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    try {
      await _health.requestAuthorization(types, permissions: permissions);

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // 🚀 1. 걸음수는 무조건 구글의 '중복 제거' API를 써야 합니다! (스마트폰 + 워치 중복 뻥튀기 방지)
      int? totalSteps = await _health.getTotalStepsInInterval(midnight, now);

      // 2. 나머지 데이터는 쪼가리(Raw)로 가져와서 우리가 정교하게 파싱합니다.
      // ⚠️ 주의: STEPS는 1번에서 구했으므로 types 배열에서 뺐습니다!
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: [
          HealthDataType.DISTANCE_DELTA,
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED,
          HealthDataType.WORKOUT,
        ],
        startTime: midnight,
        endTime: now,
      );

      double totalMeters = 0.0;
      double activeKcal = 0.0;
      double totalBurnedKcal = 0.0;

      for (var point in healthData) {
        try {
          if (point.value is NumericHealthValue) {
            double pointValue = (point.value as NumericHealthValue).numericValue.toDouble();

            if (point.type == HealthDataType.DISTANCE_DELTA) {
              totalMeters += pointValue;
            } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              activeKcal += pointValue;
            } else if (point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
              totalBurnedKcal += pointValue;
            }
          }
          // 🚀 3. WORKOUT(운동 세션) 덩어리 데이터 까보기!
          else if (point.value is WorkoutHealthValue && point.type == HealthDataType.WORKOUT) {
            var workout = point.value as WorkoutHealthValue;

            // 거리는 DISTANCE_DELTA에서 받았으니 생략, 숨겨진 운동 칼로리만 빼옵니다!
            if (workout.totalEnergyBurned != null) {
              activeKcal += workout.totalEnergyBurned!.toDouble();
            }
          }
          else {
            double pointValue = double.parse(point.value.toString());

            if (point.type == HealthDataType.DISTANCE_DELTA) {
              totalMeters += pointValue;
            } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
              activeKcal += pointValue;
            } else if (point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
              totalBurnedKcal += pointValue;
            }
          }
        } catch (e) {
          debugPrint("데이터 파싱 실패 (${point.type}): ${point.value}");
          continue;
        }
      }

      debugPrint("KaloMon 최종 데이터 - 걸음수: $totalSteps, 거리: $totalMeters, 활동칼로리: $activeKcal, 총칼로리: $totalBurnedKcal");

      return {
        'steps': totalSteps ?? 0,
        'distanceKm': totalMeters / 1000.0,
        'calories': activeKcal,
        'totalCalories': totalBurnedKcal,
      };

    } catch (e) {
      debugPrint("건강 데이터 동기화 에러: $e");
      return null;
    }
  }
}