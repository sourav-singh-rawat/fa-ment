import 'package:fave/features/payment/data/i.local_payment_repository.dart'
    show LocalPaymentRepositoryImpl;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;

abstract class PaymentRepository {
  factory PaymentRepository.local() => LocalPaymentRepositoryImpl();

  Future<void> save(Payment payment);

  Future<void> update(Payment payment);

  Future<List<Payment>> loadRecent();
}
