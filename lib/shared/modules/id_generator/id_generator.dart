import 'package:fave/shared/modules/id_generator/i.id_generator.dart'
    show UuidIdGenerator;

abstract interface class IdGenerator {
  const IdGenerator._();

  factory IdGenerator.uuid() => UuidIdGenerator();

  String generate();
}
