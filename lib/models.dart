/// Data model derived from the deck's class diagram and ERD:
/// user (customer | worker), task, payment and communication.
library;

enum UserRole { customer, worker }

enum PaymentMethod { cash, visa }

enum TaskStatus { open, accepted, completed, cancelled }

extension PaymentMethodX on PaymentMethod {
  String get label => this == PaymentMethod.cash ? 'Cash' : 'Visa';
}

extension UserRoleX on UserRole {
  String get label => this == UserRole.customer ? 'Customer' : 'Worker';
}

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.rating = 4.8,
  });

  final String id;
  String name;
  String email;
  String phone;
  final UserRole role;
  double rating;
}

class ChatMessage {
  ChatMessage({required this.fromMe, required this.text, required this.time});
  final bool fromMe;
  final String text;
  final DateTime time;
}

/// A task a customer wants done (the ERD's `task` table, plus payment fields).
class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.area,
    required this.address,
    required this.price,
    required this.method,
    required this.time,
    required this.durationMinutes,
    required this.customerName,
    this.status = TaskStatus.open,
    this.workerName,
    this.workerRating,
    this.customerRating,
    this.ratingForWorker,
    this.ratingForCustomer,
  });

  final String id;
  String title;
  String description;
  String area;
  String address;
  int price;
  PaymentMethod method;
  DateTime time;
  int durationMinutes;
  final String customerName;
  TaskStatus status;
  String? workerName;
  double? workerRating;
  double? customerRating;

  /// Stars given by the customer to the worker, and vice versa.
  int? ratingForWorker;
  int? ratingForCustomer;

  final List<ChatMessage> messages = [];

  String get priceLabel => '$price L.E.';
}
