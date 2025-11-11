import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memo.dart';

class MemoStorage {
  static const String _memosKey = 'memos';

  Future<List<Memo>> loadMemos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? memosJson = prefs.getString(_memosKey);

      if (memosJson == null || memosJson.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(memosJson);
      return decodedList.map((json) => Memo.fromJson(json)).toList();
    } catch (e) {
      print('Error loading memos: $e');
      return [];
    }
  }

  Future<void> saveMemos(List<Memo> memos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String memosJson = jsonEncode(memos.map((memo) => memo.toJson()).toList());
      await prefs.setString(_memosKey, memosJson);
    } catch (e) {
      print('Error saving memos: $e');
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_memosKey);
  }
}
