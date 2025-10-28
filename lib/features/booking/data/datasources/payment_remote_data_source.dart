import '../models/payment_model.dart';
import '../models/final_payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getByBookingId(String bookingId);

  Future<FinalPaymentModel> createFinalPayment({
    required String bookingId,
    required String paymentMethod, // 'VNPAY' | 'MOMO' | 'CASH'
  });
}
