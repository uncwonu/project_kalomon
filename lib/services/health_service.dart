// lib/services/health_service.dart

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  final Health _health = Health();

  // 🚀 헬스 커넥트에서 오늘 데이터를 싹 긁어와서 Map(사전) 형태로 깔끔하게 반환하는 함수
  Future<Map<String, dynamic>?> fetchTodayHealthData() async {
    await Permission.activityRecognition.request();

    var types = [
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_DELTA,
      HealthDataType.ACTIVE_ENERGY_BURNED, // 활동 칼로리
    ];

    var permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    try {
      // 권한 요청
      await _health.requestAuthorization(types, permissions: permissions);

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // 걸음수 추출
      int? totalSteps = await _health.getTotalStepsInInterval(midnight, now);

      // 거리 및 칼로리 추출
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types, startTime: midnight, endTime: now,
      );

      double totalMeters = 0.0;
      double totalKcal = 0.0;

      for (var point in healthData) {
        double pointValue = 0.0;
        if (point.value is NumericHealthValue) {
          pointValue = (point.value as NumericHealthValue).numericValue.toDouble();
        } else {
          pointValue = double.tryParse(point.value.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        }

        if (point.type == HealthDataType.DISTANCE_DELTA) {
          totalMeters += pointValue;
        } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          totalKcal += pointValue;
        }
      }

      // 깔끔하게 포장해서 전달!
      return {
        'steps': totalSteps ?? 0,
        'distanceKm': totalMeters / 1000.0,
        'calories': totalKcal,
      };

    } catch (e) {
      debugPrint("건강 데이터 동기화 에러: $e");
      return null; // 에러가 나면 null을 반환해서 실패했음을 알림
    }
  }
}