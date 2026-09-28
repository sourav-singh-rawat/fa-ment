import 'package:fave/features/payment/domain/entities/recipient.dart'
    show Recipient;

class SeededRecipients {
  const SeededRecipients._();

  static const List<Recipient> all = [
    Recipient(
      id: 'r1',
      name: 'Kavya Sridharan Venkataraghavan',
      handle: 'kavya.sv@okaxis',
    ),
    Recipient(id: 'r2', name: 'Rohit Menon', handle: 'rohit.menon@ybl'),
    Recipient(id: 'r3', name: 'Anaya Rao', handle: 'anaya@okhdfcbank'),
    Recipient(id: 'r4', name: 'Sunita (maid)', handle: '9876501234@paytm'),
    Recipient(
      id: 'r5',
      name: 'Bandra flat — electricity',
      handle: 'bescom.bandra.westblock.meter7@icici',
    ),
  ];

  static Recipient byId(String id) {
    return SeededRecipients.all.firstWhere((e) => e.id == id);
  }

  static Recipient get defaultRecipient => all.first;
}
