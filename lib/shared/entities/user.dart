import 'package:equatable/equatable.dart' show Equatable;

class User extends Equatable {
  final String id;
  const new({required this.id});

  @override
  List<Object?> get props => [id];
}
