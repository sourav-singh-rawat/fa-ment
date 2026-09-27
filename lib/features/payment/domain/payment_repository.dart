import 'package:fave/features/payment/data/i_payment_repository/i.local_payment_repository.dart'
    show LocalPaymentRepositoryImpl;
import 'package:fave/features/payment/domain/entities/payment.dart'
    show Payment;

abstract class PaymentRepository {
  const PaymentRepository._();
  factory PaymentRepository.local() => LocalPaymentRepositoryImpl();

  Future<void> save(Payment payment);

  Future<Payment?> get(String key);

  Future<void> update(Payment payment);

  Future<List<Payment>> loadRecent();
}
