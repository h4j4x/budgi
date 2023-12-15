import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get addAction => 'Add';

  @override
  String appAbout(String version, int year) {
    return 'v$version - Sp1k_e $year';
  }

  @override
  String get appTitle => 'Budg1';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get budgetAmountCategoryHint => 'Select budget category';

  @override
  String get budgetAmountDelete => 'Delete budget amount';

  @override
  String budgetAmountDeleteConfirm(String name) {
    return 'Confirm to delete budget amount of $name.';
  }

  @override
  String get budgetAmountHint => 'Enter budget amount...';

  @override
  String get budgetCategory => 'Budget category';

  @override
  String get budgetCategoryDelete => 'Delete category';

  @override
  String budgetCategoryDeleteConfirm(String name) {
    return 'Confirm to delete category $name.';
  }

  @override
  String get budgetsAmounts => 'Budgets amounts';

  @override
  String get budgetsCategories => 'Budgets categories';

  @override
  String get budgetsCategoriesAmounts => 'Budgets categories amounts';

  @override
  String get budgetsCategoryAmount => 'Budget category amount';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get categoriesExpenses => 'Categories expenses';

  @override
  String get category => 'Category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameHint => 'Enter category name...';

  @override
  String get copyingPreviousPeriod => 'Copying previous period amounts. Please wait...';

  @override
  String get createAction => 'Create';

  @override
  String dateMonthYear(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMM(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get editAction => 'Edit';

  @override
  String get fromDate => 'From date';

  @override
  String get home => 'Home';

  @override
  String get invalidBudgetAmount => 'Invalid budget amount. Enter a non negative number for amount.';

  @override
  String get invalidBudgetCategory => 'Invalid category.';

  @override
  String invalidBudgetCategoryName(int maxLength) {
    return 'Invalid budget category name. Enter a non empty name with no more than $maxLength characters.';
  }

  @override
  String get invalidTransactionAmount => 'Invalid transaction amount. Enter a non negative number for amount.';

  @override
  String invalidTransactionDescription(int maxLength) {
    return 'Invalid transaction description. Enter an optional description with no more than $maxLength characters.';
  }

  @override
  String get invalidTransactionType => 'Invalid transaction type';

  @override
  String get invalidTransactionWallet => 'Invalid wallet';

  @override
  String get invalidTransactionTargetWallet => 'Invalid target wallet';

  @override
  String get invalidUser => 'Invalid user';

  @override
  String get invalidUserAccess => 'Could not access user info.';

  @override
  String get invalidUserCredentials => 'Invalid credentials.';

  @override
  String get invalidUserEmail => 'Enter a valid email address.';

  @override
  String invalidUserPassword(int minLength) {
    return 'Enter a valid password with no less than $minLength characters.';
  }

  @override
  String get invalidWallet => 'Invalid wallet.';

  @override
  String invalidWalletName(int maxLength) {
    return 'Invalid wallet name. Enter a non empty name with no more than $maxLength characters.';
  }

  @override
  String get invalidWalletType => 'Invalid wallet type.';

  @override
  String get no => 'No';

  @override
  String get nothingHere => 'Nothing here :(';

  @override
  String get okAction => 'Ok';

  @override
  String prefixWithDate(String prefix, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$prefix$dateString';
  }

  @override
  String get saveAction => 'Save';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInGithub => 'Sign in with github';

  @override
  String get signOut => 'Sign out';

  @override
  String get sortAsc => 'Sort asc';

  @override
  String get sortByAmount => 'Sort by amount';

  @override
  String get sortByDateTime => 'Sort by datetime';

  @override
  String get sortDesc => 'Sort desc';

  @override
  String get toDate => 'To date';

  @override
  String get transaction => 'Transaction';

  @override
  String get transactionAmount => 'Transaction amount';

  @override
  String get transactionAmountHint => 'Enter transaction amount...';

  @override
  String get transactionCategoryHint => 'Select transaction category';

  @override
  String get transactionDelete => 'Delete transaction';

  @override
  String transactionDeleteConfirm(String description) {
    return 'Confirm to delete transaction $description.';
  }

  @override
  String get transactionDescription => 'Transaction description';

  @override
  String get transactionDescriptionHint => 'Enter transaction description...';

  @override
  String get transactions => 'Transactions';

  @override
  String get transactionsFilters => 'Filter transactions';

  @override
  String get transactionStatus => 'Transaction status';

  @override
  String get transactionStatusCompleted => 'Completed';

  @override
  String get transactionStatusHint => 'Select transaction status';

  @override
  String get transactionStatusPendent => 'Pendent';

  @override
  String get transactionType => 'Transaction type';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get transactionTypeIncomeTransfer => 'Transfer income';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get transactionTypeExpenseTransfer => 'Transfer expense';

  @override
  String get transactionTypeHint => 'Select transaction type';

  @override
  String get transactionTypeWalletTransfer => ' Wallet transfer';

  @override
  String get transactionWalletHint => 'Select transaction wallet';

  @override
  String get transactionWalletSourceHint => 'Select source transaction wallet';

  @override
  String get transactionWalletTargetHint => 'Select target transaction wallet';

  @override
  String transferFrom(String source) {
    return 'Transfer from $source.';
  }

  @override
  String transferTo(String target) {
    return 'Transfer to $target.';
  }

  @override
  String get userEmail => 'Email';

  @override
  String get userEmailHint => 'Enter email...';

  @override
  String get userPassword => 'Password';

  @override
  String get userPasswordHint => 'Enter password...';

  @override
  String get userSignIn => 'Sign in';

  @override
  String get wallet => 'Wallet';

  @override
  String get walletDelete => 'Delete wallet';

  @override
  String walletDeleteConfirm(String name) {
    return 'Confirm to delete wallet $name.';
  }

  @override
  String get walletName => 'Wallet name';

  @override
  String get walletNameHint => 'Enter wallet name...';

  @override
  String get wallets => 'Wallets';

  @override
  String get walletsBalance => 'Wallets balance';

  @override
  String get walletTypeCash => 'Cash';

  @override
  String get walletTypeCreditCard => 'Credit card';

  @override
  String get walletTypeDebitCard => 'Debit card';

  @override
  String get walletTypeHint => 'Select wallet type';

  @override
  String get yes => 'Yes';
}
