import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/memo_provider.dart';
import 'screens/memo_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemoProvider(),
      child: MaterialApp(
        title: '备忘录',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF34C759), // 苹果绿色主题
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: '.SF Pro Text', // 苹果字体
          scaffoldBackgroundColor: const Color(0xFFF2F2F7),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const MemoListScreen(),
      ),
    );
  }
}
