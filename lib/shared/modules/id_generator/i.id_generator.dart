import 'package:fave/shared/modules/id_generator/id_generator.dart'
    show IdGenerator;
import 'package:uuid/uuid.dart' show Uuid;

class UuidIdGenerator implements IdGenerator {
  @override
  String generate() => const Uuid().v4();
}
