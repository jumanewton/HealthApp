// test/unit/bmi_calculator_test.dart

import 'package:flutter_test/flutter_test.dart';

// Import your BMI calculator function or create one
class HealthMetricsCalculator {
  static String calculateBMI(Map<String, dynamic> user) {
    final height = user['height'] != null
        ? double.tryParse(user['height'].toString())
        : null;
    final weight = user['weight'] != null
        ? double.tryParse(user['weight'].toString())
        : null;

    if (height == null || weight == null || height == 0) return '--';

    final bmi = weight / ((height / 100) * (height / 100));
    return bmi.toStringAsFixed(1);
  }
}

void main() {
  group('BMI Calculator', () {
    test('calculateBMI returns correct value with valid height and weight', () {
      final userData = {
        'height': '180',
        'weight': '75',
      };
      
      final result = HealthMetricsCalculator.calculateBMI(userData);
      
      // 75 / ((180/100) * (180/100)) = 75 / 3.24 = 23.15
      expect(result, '23.1');
    });

    test('calculateBMI returns placeholder when height is missing', () {
      final userData = {
        'weight': '75',
      };
      
      final result = HealthMetricsCalculator.calculateBMI(userData);
      expect(result, '--');
    });

    test('calculateBMI returns placeholder when weight is missing', () {
      final userData = {
        'height': '180',
      };
      
      final result = HealthMetricsCalculator.calculateBMI(userData);
      expect(result, '--');
    });

    test('calculateBMI returns placeholder when height is zero', () {
      final userData = {
        'height': '0',
        'weight': '75',
      };
      
      final result = HealthMetricsCalculator.calculateBMI(userData);
      expect(result, '--');
    });

    test('calculateBMI handles string values correctly', () {
      final userData = {
        'height': '165.5',
        'weight': '62.3',
      };
      
      final result = HealthMetricsCalculator.calculateBMI(userData);
      
      // 62.3 / ((165.5/100) * (165.5/100)) = 62.3 / 2.74 ≈ 22.7
      expect(result, '22.7');
    });
  });
}