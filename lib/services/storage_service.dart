import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_location.dart';

class StorageService {
  static const String _key = 'parking_locations';
  static const int maxStorageCount = 10; // 최대 저장 개수 제한

  // 주차 위치 저장
  Future<void> saveParkingLocation(ParkingLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    final locations = await getParkingLocations();

    locations.insert(0, location); // 최신 항목을 맨 앞에 추가

    // 최대 저장 개수를 초과하는 경우 오래된 기록 삭제
    if (locations.length > maxStorageCount) {
      locations.removeRange(maxStorageCount, locations.length);
    }

    final jsonList = locations.map((loc) => loc.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  // 저장된 주차 위치 목록 조회
  Future<List<ParkingLocation>> getParkingLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => ParkingLocation.fromJson(json)).toList();
  }

  // 주차 위치 삭제
  Future<void> deleteParkingLocation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final locations = await getParkingLocations();

    locations.removeWhere((location) => location.id == id);

    final jsonList = locations.map((loc) => loc.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  // 모든 주차 위치 삭제
  Future<void> clearAllParkingLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
