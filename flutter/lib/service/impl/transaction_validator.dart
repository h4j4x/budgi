import '../../app/config.dart';
import '../../model/domain/transaction.dart';
import '../../model/error/transaction.dart';
import '../validator.dart';

class TransactionValidator implements Validator<Transaction, TransactionError> {
  static const String transactionType = 'transactionType';
  static const String category = 'category';
  static const String wallet = 'wallet';
  static const String walletTarget = 'walletTarget';
  static const String amount = 'amount';
  static const String description = 'description';

  @override
  Map<String, TransactionError> validate(Transaction item) {
    final errors = <String, TransactionError>{};
    if (item.description.length > AppConfig.textFieldMaxLength) {
      errors[description] = TransactionError.invalidDescription;
    }
    if (item.amount <= 0) {
      errors[amount] = TransactionError.invalidAmount;
    }
    return errors;
  }
}
