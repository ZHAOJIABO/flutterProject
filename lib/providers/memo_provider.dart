import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/memo.dart';
import '../services/memo_storage.dart';

enum TimeFilter {
  all,
  today,
  tomorrow,
  thisWeek,
  thisMonth,
}

class MemoProvider with ChangeNotifier {
  List<Memo> _memos = [];
  TimeFilter _currentFilter = TimeFilter.all;
  final MemoStorage _storage = MemoStorage();
  final Uuid _uuid = const Uuid();

  List<Memo> get memos {
    final now = DateTime.now();
    final filteredMemos = _memos.where((memo) {
      switch (_currentFilter) {
        case TimeFilter.today:
          return _isSameDay(memo.reminderTime, now);
        case TimeFilter.tomorrow:
          final tomorrow = now.add(const Duration(days: 1));
          return _isSameDay(memo.reminderTime, tomorrow);
        case TimeFilter.thisWeek:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 7));
          return memo.reminderTime.isAfter(weekStart) &&
              memo.reminderTime.isBefore(weekEnd);
        case TimeFilter.thisMonth:
          return memo.reminderTime.year == now.year &&
              memo.reminderTime.month == now.month;
        case TimeFilter.all:
          return true;
      }
    }).toList();

    // 按时间排序
    filteredMemos.sort((a, b) => a.reminderTime.compareTo(b.reminderTime));
    return filteredMemos;
  }

  TimeFilter get currentFilter => _currentFilter;

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> loadMemos() async {
    _memos = await _storage.loadMemos();
    notifyListeners();
  }

  Future<void> addMemo({
    required String title,
    required String content,
    required DateTime reminderTime,
  }) async {
    final memo = Memo(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      reminderTime: reminderTime,
    );

    _memos.add(memo);
    await _storage.saveMemos(_memos);
    notifyListeners();
  }

  Future<void> updateMemo(Memo updatedMemo) async {
    final index = _memos.indexWhere((memo) => memo.id == updatedMemo.id);
    if (index != -1) {
      _memos[index] = updatedMemo;
      await _storage.saveMemos(_memos);
      notifyListeners();
    }
  }

  Future<void> deleteMemo(String id) async {
    _memos.removeWhere((memo) => memo.id == id);
    await _storage.saveMemos(_memos);
    notifyListeners();
  }

  Future<void> toggleComplete(String id) async {
    final index = _memos.indexWhere((memo) => memo.id == id);
    if (index != -1) {
      _memos[index] = _memos[index].copyWith(
        isCompleted: !_memos[index].isCompleted,
      );
      await _storage.saveMemos(_memos);
      notifyListeners();
    }
  }

  void setFilter(TimeFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }
}
