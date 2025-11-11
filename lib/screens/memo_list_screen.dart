import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/memo_provider.dart';
import '../models/memo.dart';
import 'add_edit_memo_screen.dart';

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  State<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemoProvider>(context, listen: false).loadMemos();
    });
  }

  String _getFilterText(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.all:
        return '全部';
      case TimeFilter.today:
        return '今天';
      case TimeFilter.tomorrow:
        return '明天';
      case TimeFilter.thisWeek:
        return '本周';
      case TimeFilter.thisMonth:
        return '本月';
    }
  }

  Widget _buildFilterChip(TimeFilter filter, MemoProvider provider) {
    final isSelected = provider.currentFilter == filter;
    return GestureDetector(
      onTap: () => provider.setFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF34C759) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          _getFilterText(filter),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMemoCard(Memo memo, MemoProvider provider) {
    final now = DateTime.now();
    final isOverdue = memo.reminderTime.isBefore(now) && !memo.isCompleted;
    final timeText = DateFormat('MM月dd日 HH:mm').format(memo.reminderTime);

    return Dismissible(
      key: Key(memo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(CupertinoIcons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        provider.deleteMemo(memo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('备忘录已删除'),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditMemoScreen(memo: memo),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 完成状态按钮
              GestureDetector(
                onTap: () => provider.toggleComplete(memo.id),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: memo.isCompleted
                          ? const Color(0xFF34C759)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: memo.isCompleted
                        ? const Color(0xFF34C759)
                        : Colors.transparent,
                  ),
                  child: memo.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // 备忘录内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memo.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: memo.isCompleted
                            ? Colors.grey
                            : Colors.black87,
                        decoration: memo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (memo.content.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        memo.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          decoration: memo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 14,
                          color: isOverdue ? Colors.red : const Color(0xFF34C759),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 13,
                            color: isOverdue ? Colors.red : Colors.grey.shade600,
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '已逾期',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题和筛选器
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '备忘录',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<MemoProvider>(
                    builder: (context, provider, _) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(TimeFilter.all, provider),
                            const SizedBox(width: 8),
                            _buildFilterChip(TimeFilter.today, provider),
                            const SizedBox(width: 8),
                            _buildFilterChip(TimeFilter.tomorrow, provider),
                            const SizedBox(width: 8),
                            _buildFilterChip(TimeFilter.thisWeek, provider),
                            const SizedBox(width: 8),
                            _buildFilterChip(TimeFilter.thisMonth, provider),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 备忘录列表
            Expanded(
              child: Consumer<MemoProvider>(
                builder: (context, provider, _) {
                  final memos = provider.memos;

                  if (memos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.doc_text,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无备忘录',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: memos.length,
                    itemBuilder: (context, index) {
                      return _buildMemoCard(memos[index], provider);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34C759), Color(0xFF30D158)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF34C759).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditMemoScreen(),
                ),
              );
            },
            child: const Icon(
              CupertinoIcons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
