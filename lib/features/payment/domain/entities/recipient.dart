import 'package:fave/shared/entities/user.dart' show User;

class Recipient extends User {
  final String name;
  final String handle;

  const Recipient({
    required super.id,
    required this.name,
    required this.handle,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      id: json['id'] as String,
      name: json['name'] as String,
      handle: json['handle'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'handle': handle};

  @override
  List<Object?> get props => [id, handle];
}
