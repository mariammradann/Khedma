import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models.dart';

/// In-memory app state with mock data. Replace the methods below with calls
/// to your real backend (REST / Firebase / Supabase) when it exists.
class AppState extends ChangeNotifier {
  AppState() {
    final now = DateTime.now();
    DateTime at(int h, int m) => DateTime(now.year, now.month, now.day, h, m);
    tasks.addAll([
      TaskItem(
        id: 't1',
        title: 'Want a ride to Maadi',
        description: 'Need a lift from Mokattam to Maadi, one passenger.',
        area: 'Mokattam',
        address: 'Road 9',
        price: 50,
        method: PaymentMethod.cash,
        time: at(17, 0),
        durationMinutes: 45,
        customerName: 'Nour Amr',
      ),
      TaskItem(
        id: 't2',
        title: 'Want to wash her car',
        description: 'Exterior wash for a small hatchback.',
        area: 'Mokattam',
        address: 'Karim Banona',
        price: 70,
        method: PaymentMethod.visa,
        time: at(18, 30),
        durationMinutes: 60,
        customerName: 'Hana Sherif',
      ),
      TaskItem(
        id: 't3',
        title: 'Groceries from the supermarket',
        description: 'Pick up a short list and bring it home.',
        area: 'Fifth Settlement',
        address: 'South Teseen St.',
        price: 40,
        method: PaymentMethod.cash,
        time: at(16, 15),
        durationMinutes: 30,
        customerName: 'Omar Tarek',
      ),
      TaskItem(
        id: 't4',
        title: 'Mow the front lawn',
        description: 'Small garden, mower provided.',
        area: 'Maadi',
        address: 'Road 233',
        price: 90,
        method: PaymentMethod.cash,
        time: at(19, 0),
        durationMinutes: 90,
        customerName: 'Salma Adel',
      ),
    ]);
  }

  static const areas = [
    'Mokattam',
    'Fifth Settlement',
    'Maadi',
    'Nasr City',
    'Zamalek',
  ];

  AppUser? user;
  String selectedArea = 'Mokattam';
  final List<TaskItem> tasks = [];
  final Set<String> declined = {};
  int _nextId = 100;

  // ---- auth -------------------------------------------------------------

  void login({required String identifier, required UserRole role}) {
    final isEmail = identifier.contains('@');
    final base = isEmail ? identifier.split('@').first : 'Khedma user';
    user = AppUser(
      id: 'u1',
      name: _titleCase(base.replaceAll(RegExp(r'[._-]+'), ' ')),
      email: isEmail ? identifier : '',
      phone: isEmail ? '' : identifier,
      role: role,
    );
    notifyListeners();
  }

  void signUp({
    required String name,
    required String email,
    required String phone,
    required UserRole role,
  }) {
    user = AppUser(
      id: 'u1',
      name: name,
      email: email,
      phone: phone,
      role: role,
      rating: 5.0,
    );
    notifyListeners();
  }

  void logout() {
    user = null;
    declined.clear();
    notifyListeners();
  }

  // ---- area -------------------------------------------------------------

  void selectArea(String area) {
    selectedArea = area;
    notifyListeners();
  }

  // ---- tasks ------------------------------------------------------------

  TaskItem? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Open tasks a worker can see in the selected area.
  List<TaskItem> get nearbyTasks => tasks
      .where((t) =>
          t.status == TaskStatus.open &&
          t.area == selectedArea &&
          !declined.contains(t.id) &&
          t.customerName != user?.name)
      .toList();

  /// Tasks that belong to the signed-in user, newest first.
  List<TaskItem> get myTasks {
    final u = user;
    if (u == null) return const [];
    final list = tasks
        .where((t) => u.role == UserRole.customer
            ? t.customerName == u.name
            : t.workerName == u.name)
        .toList();
    return list.reversed.toList();
  }

  TaskItem addTask({
    required String title,
    required String description,
    required String area,
    required String address,
    required int price,
    required PaymentMethod method,
    required DateTime time,
    required int durationMinutes,
  }) {
    final t = TaskItem(
      id: 't${_nextId++}',
      title: title,
      description: description,
      area: area,
      address: address,
      price: price,
      method: method,
      time: time,
      durationMinutes: durationMinutes,
      customerName: user!.name,
    );
    tasks.add(t);
    notifyListeners();

    // MOCK BACKEND: a nearby worker accepts the request after a few seconds.
    Timer(const Duration(seconds: 6), () {
      if (t.status == TaskStatus.open) {
        t.status = TaskStatus.accepted;
        t.workerName = 'Amr Hussein';
        t.workerRating = 4.8;
        notifyListeners();
      }
    });
    return t;
  }

  void accept(TaskItem t) {
    t.status = TaskStatus.accepted;
    t.workerName = user!.name;
    t.workerRating = user!.rating;
    t.customerRating = 4.7;
    notifyListeners();
  }

  void decline(TaskItem t) {
    declined.add(t.id);
    notifyListeners();
  }

  void cancel(TaskItem t) {
    t.status = TaskStatus.cancelled;
    notifyListeners();
  }

  /// Worker ends the task; both sides then see the payment receipt.
  void complete(TaskItem t) {
    t.status = TaskStatus.completed;
    notifyListeners();
  }

  void rate(TaskItem t, {required bool ratingTheWorker, required int stars}) {
    if (ratingTheWorker) {
      t.ratingForWorker = stars;
    } else {
      t.ratingForCustomer = stars;
    }
    notifyListeners();
  }

  // ---- communication ----------------------------------------------------

  void sendMessage(TaskItem t, String text) {
    t.messages.add(ChatMessage(fromMe: true, text: text, time: DateTime.now()));
    notifyListeners();
    // MOCK BACKEND: canned reply.
    Timer(const Duration(seconds: 2), () {
      t.messages.add(ChatMessage(
        fromMe: false,
        text: 'Got it, see you soon!',
        time: DateTime.now(),
      ));
      notifyListeners();
    });
  }

  // ---- stats for profile -----------------------------------------------

  int get totalAmount => myTasks
      .where((t) => t.status == TaskStatus.completed)
      .fold(0, (sum, t) => sum + t.price);

  int get completedCount =>
      myTasks.where((t) => t.status == TaskStatus.completed).length;

  static String _titleCase(String s) => s
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

/// Single app-wide instance (simple on purpose; swap for Provider/Riverpod
/// if the app grows).
final AppState appState = AppState();
