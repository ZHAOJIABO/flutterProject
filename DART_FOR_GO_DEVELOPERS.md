# Dart 快速上手指南 - 给 Go 开发者

## 目录
1. [核心概念对比](#核心概念对比)
2. [语法差异](#语法差异)
3. [类型系统](#类型系统)
4. [并发模型](#并发模型)
5. [包管理](#包管理)
6. [常用模式](#常用模式)

---

## 核心概念对比

| 特性 | Go | Dart |
|------|-----|------|
| 面向对象 | 结构体+接口 | 类+接口 |
| 并发 | goroutine + channel | async/await + Future/Stream |
| 包管理 | go mod | pub/pubspec.yaml |
| 编译 | 编译型 | JIT + AOT |
| 空安全 | 指针可为nil | null safety (可空类型) |

---

## 语法差异

### 1. 变量声明

```dart
// Go
var name string = "John"
name := "John"
const PI = 3.14

// Dart
String name = "John";
var name = "John";              // 类型推断
final name = "John";            // 运行时常量(类似 Go 的普通变量,但不可变)
const PI = 3.14;                // 编译时常量

// Dart 的可空类型
String? nullableName = null;    // ? 表示可空
String name = nullableName ?? "default";  // ?? 是空合并操作符
```

### 2. 函数

```dart
// Go
func add(a, b int) int {
    return a + b
}

func divide(a, b int) (int, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}

// Dart
int add(int a, int b) {
  return a + b;
}

// 箭头函数(单表达式)
int add(int a, int b) => a + b;

// 命名参数
void greet({required String name, int age = 18}) {
  print('Hello $name, age: $age');
}
greet(name: "John");  // 调用时必须指定参数名

// 位置可选参数
int sum(int a, [int b = 0, int c = 0]) {
  return a + b + c;
}
sum(1);       // 1
sum(1, 2);    // 3
sum(1, 2, 3); // 6
```

### 3. 结构体 vs 类

```dart
// Go
type Person struct {
    Name string
    Age  int
}

func NewPerson(name string) *Person {
    return &Person{Name: name, Age: 0}
}

func (p *Person) Greet() string {
    return "Hello, " + p.Name
}

// Dart
class Person {
  String name;
  int age;

  // 构造函数
  Person(this.name, this.age);

  // 命名构造函数
  Person.fromName(this.name) : age = 0;

  // 方法
  String greet() {
    return 'Hello, $name';
  }

  // Getter
  bool get isAdult => age >= 18;

  // Setter
  set age(int value) {
    if (value >= 0) age = value;
  }
}

// 使用
var person = Person("John", 25);
var person2 = Person.fromName("Jane");
```

### 4. 接口

```dart
// Go
type Greeter interface {
    Greet() string
}

type Person struct {
    Name string
}

func (p Person) Greet() string {
    return "Hello, " + p.Name
}

// Dart - 使用抽象类或隐式接口
abstract class Greeter {
  String greet();
}

class Person implements Greeter {
  final String name;

  Person(this.name);

  @override
  String greet() {
    return 'Hello, $name';
  }
}

// Dart 中每个类都隐式定义了一个接口
class Animal {
  void makeSound() => print('Some sound');
}

class Dog implements Animal {
  @override
  void makeSound() => print('Woof!');
}
```

### 5. 错误处理

```dart
// Go
result, err := someFunction()
if err != nil {
    return err
}

// Dart - 使用异常
try {
  var result = someFunction();
} catch (e) {
  print('Error: $e');
} finally {
  // 清理代码
}

// Dart - 返回可空类型
String? findUser(String id) {
  // 返回 null 表示未找到
  return null;
}

var user = findUser("123");
if (user != null) {
  print(user);
}
```

---

## 类型系统

### 基本类型

```dart
// 数值类型
int age = 25;
double price = 19.99;
num flexible = 10;    // int 或 double

// 字符串
String name = "John";
String multiline = '''
  This is
  multiline
''';

// 字符串插值
String greeting = "Hello, $name";
String info = "Age: ${age + 1}";

// 布尔
bool isActive = true;

// 列表 (类似 Go 的 slice)
List<int> numbers = [1, 2, 3];
var list = <String>['a', 'b', 'c'];
list.add('d');

// 扩展运算符
var combined = [...numbers, 4, 5];

// Map (类似 Go 的 map)
Map<String, int> ages = {
  'John': 25,
  'Jane': 30,
};

// Set
Set<int> uniqueNumbers = {1, 2, 3, 3}; // {1, 2, 3}
```

### 空安全

```dart
// 可空类型
String? nullableName;
String name = "John";  // 不可为 null

// 安全调用
int? length = nullableName?.length;  // 类似 Go: if name != nil { len(*name) }

// 非空断言 (确定不为 null 时使用)
String definitelyNotNull = nullableName!;

// 空合并
String displayName = nullableName ?? "Guest";

// 空赋值
nullableName ??= "Default";  // 仅当为 null 时赋值
```

---

## 并发模型

### Go 的 goroutine vs Dart 的 async/await

```dart
// Go
func fetchData() {
    go func() {
        data := heavyOperation()
        channel <- data
    }()
}

// Dart
Future<String> fetchData() async {
  // async 函数自动在事件循环中执行
  var data = await heavyOperation();
  return data;
}

// 使用
void main() async {
  var result = await fetchData();
  print(result);
}
```

### Future (类似 Go 的 channel + goroutine)

```dart
// 创建 Future
Future<int> expensiveCalculation() {
  return Future.delayed(Duration(seconds: 2), () => 42);
}

// 链式调用
expensiveCalculation()
  .then((value) => print(value))
  .catchError((error) => print('Error: $error'));

// async/await 方式
Future<void> doWork() async {
  try {
    var result = await expensiveCalculation();
    print(result);
  } catch (e) {
    print('Error: $e');
  }
}

// 并发执行多个 Future (类似 Go 的 WaitGroup)
Future<void> fetchMultiple() async {
  var results = await Future.wait([
    fetchUser(),
    fetchPosts(),
    fetchComments(),
  ]);

  var user = results[0];
  var posts = results[1];
  var comments = results[2];
}
```

### Stream (类似 Go 的 channel)

```dart
// Go
ch := make(chan int)
go func() {
    for i := 0; i < 5; i++ {
        ch <- i
    }
    close(ch)
}()

for val := range ch {
    fmt.Println(val)
}

// Dart
Stream<int> countStream() async* {
  for (int i = 0; i < 5; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;  // 类似 Go 的 ch <- i
  }
}

// 消费 Stream
await for (var value in countStream()) {
  print(value);
}

// 或使用 listen
countStream().listen(
  (value) => print(value),
  onError: (error) => print('Error: $error'),
  onDone: () => print('Done'),
);
```

---

## 包管理

### Go Modules vs Pub

```yaml
# pubspec.yaml (类似 go.mod)
name: my_app
description: A Flutter app
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  # 类似 go get
  http: ^1.0.0
  uuid: ^4.0.0

dev_dependencies:
  # 类似 go test 的依赖
  test: ^1.24.0
```

```bash
# Go
go get package
go mod tidy

# Dart
dart pub add package_name
dart pub get           # 安装依赖
dart pub upgrade       # 升级依赖
```

### 导入

```dart
// Go
import "fmt"
import "github.com/user/package"

// Dart
import 'dart:core';                    // Dart 核心库
import 'package:http/http.dart';       // 第三方包
import 'package:my_app/utils.dart';    // 项目内部包
import './local_file.dart';            // 相对路径

// 导入别名
import 'package:http/http.dart' as http;

// 只导入部分
import 'package:http/http.dart' show get, post;

// 排除部分
import 'package:http/http.dart' hide delete;
```

---

## 常用模式

### 1. 构造函数模式

```dart
class User {
  final String id;
  final String name;
  final int age;

  // 标准构造函数
  User(this.id, this.name, this.age);

  // 命名构造函数 (类似 Go 的 NewXxx 函数)
  User.guest() : id = '', name = 'Guest', age = 0;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        age = json['age'];

  // copyWith 模式 (不可变对象更新)
  User copyWith({String? id, String? name, int? age}) {
    return User(
      id ?? this.id,
      name ?? this.name,
      age ?? this.age,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }
}
```

### 2. 枚举

```dart
// Go
type Status int
const (
    Pending Status = iota
    Active
    Completed
)

// Dart
enum Status {
  pending,
  active,
  completed;

  // 枚举也可以有方法
  String get displayName {
    switch (this) {
      case Status.pending:
        return 'Pending';
      case Status.active:
        return 'Active';
      case Status.completed:
        return 'Completed';
    }
  }
}

// 使用
var status = Status.active;
print(status.displayName);
```

### 3. 扩展方法 (类似给类型添加方法)

```dart
// 为现有类型添加方法
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// 使用
var name = "john";
print(name.capitalize()); // "John"
```

### 4. Mixins (代码复用)

```dart
// 类似组合,但更灵活
mixin LoggerMixin {
  void log(String message) {
    print('[${DateTime.now()}] $message');
  }
}

mixin ValidationMixin {
  bool validate(String input) {
    return input.isNotEmpty;
  }
}

class UserService with LoggerMixin, ValidationMixin {
  void createUser(String name) {
    if (validate(name)) {
      log('Creating user: $name');
    }
  }
}
```

### 5. 集合操作

```dart
var numbers = [1, 2, 3, 4, 5];

// map (类似 Go 的循环+处理)
var doubled = numbers.map((n) => n * 2).toList();

// filter (where)
var evens = numbers.where((n) => n % 2 == 0).toList();

// reduce
var sum = numbers.reduce((a, b) => a + b);

// fold (带初始值的 reduce)
var product = numbers.fold(1, (prev, n) => prev * n);

// 链式调用
var result = numbers
    .where((n) => n > 2)
    .map((n) => n * 2)
    .toList();
```

---

## 实战示例

### HTTP 请求 (类似 Go 的 net/http)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Go
func fetchUser(id string) (*User, error) {
    resp, err := http.Get("https://api.example.com/users/" + id)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    var user User
    json.NewDecoder(resp.Body).Decode(&user)
    return &user, nil
}

// Dart
Future<User> fetchUser(String id) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/users/$id'),
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load user');
  }
}

// 使用
try {
  var user = await fetchUser('123');
  print(user.name);
} catch (e) {
  print('Error: $e');
}
```

### 文件操作

```dart
import 'dart:io';

// 读文件
Future<String> readFile(String path) async {
  final file = File(path);
  return await file.readAsString();
}

// 写文件
Future<void> writeFile(String path, String content) async {
  final file = File(path);
  await file.writeAsString(content);
}

// 检查文件是否存在
Future<bool> fileExists(String path) async {
  return await File(path).exists();
}
```

---

## 常见陷阱

### 1. 分号是必须的
```dart
// 错误
var name = "John"
print(name)

// 正确
var name = "John";
print(name);
```

### 2. 构造函数不用 new
```dart
// 旧写法 (仍然有效)
var person = new Person("John");

// 新写法 (推荐)
var person = Person("John");
```

### 3. == 比较的是值,不是引用
```dart
var list1 = [1, 2, 3];
var list2 = [1, 2, 3];
print(list1 == list2); // false (引用不同)

// 使用 identical 检查引用相同
print(identical(list1, list2)); // false

// 字符串比较是值比较
var s1 = "hello";
var s2 = "hello";
print(s1 == s2); // true
```

### 4. async 函数必须返回 Future
```dart
// 错误
async String fetchData() {  // 编译错误
  return "data";
}

// 正确
Future<String> fetchData() async {
  return "data";
}
```

---

## 快速参考

### 类型对照

| Go | Dart |
|----|------|
| `int`, `int32`, `int64` | `int` |
| `float32`, `float64` | `double` |
| `string` | `String` |
| `bool` | `bool` |
| `[]T` | `List<T>` |
| `map[K]V` | `Map<K, V>` |
| `interface{}` | `dynamic` 或 `Object` |
| `*T` | `T?` (可空类型) |

### 关键字对照

| Go | Dart |
|----|------|
| `func` | 函数类型推断或显式类型 |
| `defer` | `try-finally` |
| `go` | `async/await` |
| `chan` | `Stream` |
| `make` | 构造函数 |
| `nil` | `null` |
| `struct` | `class` |
| `interface` | `abstract class` 或隐式接口 |

---

## 学习路径建议

1. **第1天**: 基础语法、类型系统、函数
2. **第2天**: 类、构造函数、继承
3. **第3天**: 异步编程 (Future, async/await)
4. **第4天**: Stream、集合操作
5. **第5天**: 包管理、常用库、Flutter 基础

## 推荐资源

- Dart 官方文档: https://dart.dev/guides
- DartPad (在线练习): https://dartpad.dev
- Effective Dart: https://dart.dev/guides/language/effective-dart

---

## 总结

**Go 开发者学 Dart 的优势:**
- 都是强类型语言,类型安全
- 都有出色的工具链
- 都支持并发编程
- 语法相对简洁

**主要差异:**
- Dart 更面向对象 (类 vs 结构体)
- 异步模型不同 (async/await vs goroutine)
- Dart 有空安全类型系统
- Dart 主要用于 Flutter 客户端开发

作为 Go 开发者,你会发现 Dart 很容易上手。专注于理解 async/await 模型和类的使用即可快速掌握!
