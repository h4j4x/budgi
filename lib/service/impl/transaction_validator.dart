import '../../app/config.dart';
import '../../model/transaction.dart';
import '../../model/transaction_error.dart';
import '../validator.dart';

class TransactionValidator implements Validator<Transaction, TransactionError> {
  static const String description = 'description';
  static const String category = 'category';
  static const String wallet = 'wallet';
  static const String transactionType = 'transactionType';
  static const String amount = 'amount';

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
