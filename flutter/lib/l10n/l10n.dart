import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @appAbout.
  ///
  /// In en, this message translates to:
  /// **'v{version} - Sp1k_e {year}'**
  String appAbout(String version, int year);

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Budg1'**
  String get appTitle;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get budgetAmount;

  /// No description provided for @budgetAmountCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select budget category'**
  String get budgetAmountCategoryHint;

  /// No description provided for @budgetAmountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete budget amount'**
  String get budgetAmountDelete;

  /// No description provided for @budgetAmountDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm to delete budget amount of {name}.'**
  String budgetAmountDeleteConfirm(String name);

  /// No description provided for @budgetAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter budget amount...'**
  String get budgetAmountHint;

  /// No description provided for @budgetCategory.
  ///
  /// In en, this message translates to:
  /// **'Budget category'**
  String get budgetCategory;

  /// No description provided for @budgetCategoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get budgetCategoryDelete;

  /// No description provided for @budgetCategoryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm to delete category {name}.'**
  String budgetCategoryDeleteConfirm(String name);

  /// No description provided for @budgetsAmounts.
  ///
  /// In en, this message translates to:
  /// **'Budgets amounts'**
  String get budgetsAmounts;

  /// No description provided for @budgetsCategories.
  ///
  /// In en, this message translates to:
  /// **'Budgets categories'**
  String get budgetsCategories;

  /// No description provided for @budgetsCategoriesAmounts.
  ///
  /// In en, this message translates to:
  /// **'Budgets categories amounts'**
  String get budgetsCategoriesAmounts;

  /// No description provided for @budgetsCategoryAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget category amount'**
  String get budgetsCategoryAmount;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @categoriesExpenses.
  ///
  /// In en, this message translates to:
  /// **'Categories expenses'**
  String get categoriesExpenses;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter category name...'**
  String get categoryNameHint;

  /// No description provided for @copyingPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Copying previous period amounts. Please wait...'**
  String get copyingPreviousPeriod;

  /// No description provided for @createAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// No description provided for @dateMonthYear.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateMonthYear(DateTime date);

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get fromDate;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @invalidBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid budget amount. Enter a non negative number for amount.'**
  String get invalidBudgetAmount;

  /// No description provided for @invalidBudgetCategory.
  ///
  /// In en, this message translates to:
  /// **'Invalid category.'**
  String get invalidBudgetCategory;

  /// No description provided for @invalidBudgetCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Invalid budget category name. Enter a non empty name with no more than {maxLength} characters.'**
  String invalidBudgetCategoryName(int maxLength);

  /// No description provided for @invalidTransactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid transaction amount. Enter a non negative number for amount.'**
  String get invalidTransactionAmount;

  /// No description provided for @invalidTransactionDeferredMonths.
  ///
  /// In en, this message translates to:
  /// **'Invalid transaction deferred months.'**
  String get invalidTransactionDeferredMonths;

  /// No description provided for @invalidTransactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Invalid transaction description. Enter an optional description with no more than {maxLength} characters.'**
  String invalidTransactionDescription(int maxLength);

  /// No description provided for @invalidTransactionType.
  ///
  /// In en, this message translates to:
  /// **'Invalid transaction type'**
  String get invalidTransactionType;

  /// No description provided for @invalidTransactionWallet.
  ///
  /// In en, this message translates to:
  /// **'Invalid wallet'**
  String get invalidTransactionWallet;

  /// No description provided for @invalidTransactionTargetWallet.
  ///
  /// In en, this message translates to:
  /// **'Invalid target wallet'**
  String get invalidTransactionTargetWallet;

  /// No description provided for @invalidUser.
  ///
  /// In en, this message translates to:
  /// **'Invalid user'**
  String get invalidUser;

  /// No description provided for @invalidUserAccess.
  ///
  /// In en, this message translates to:
  /// **'Could not access user info.'**
  String get invalidUserAccess;

  /// No description provided for @invalidUserCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials.'**
  String get invalidUserCredentials;

  /// No description provided for @invalidUserEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidUserEmail;

  /// No description provided for @invalidUserPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid password with no less than {minLength} characters.'**
  String invalidUserPassword(int minLength);

  /// No description provided for @invalidWallet.
  ///
  /// In en, this message translates to:
  /// **'Invalid wallet.'**
  String get invalidWallet;

  /// No description provided for @invalidWalletName.
  ///
  /// In en, this message translates to:
  /// **'Invalid wallet name. Enter a non empty name with no more than {maxLength} characters.'**
  String invalidWalletName(int maxLength);

  /// No description provided for @invalidWalletType.
  ///
  /// In en, this message translates to:
  /// **'Invalid wallet type.'**
  String get invalidWalletType;

  /// No description provided for @loadingNextPage.
  ///
  /// In en, this message translates to:
  /// **'Loading next page...'**
  String get loadingNextPage;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noServerConnection.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to server :/'**
  String get noServerConnection;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here :('**
  String get nothingHere;

  /// No description provided for @okAction.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get okAction;

  /// No description provided for @pageEnd.
  ///
  /// In en, this message translates to:
  /// **'Page {number} end'**
  String pageEnd(int number);

  /// No description provided for @prefixWithDate.
  ///
  /// In en, this message translates to:
  /// **'{prefix}{date}'**
  String prefixWithDate(String prefix, DateTime date);

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @sortAsc.
  ///
  /// In en, this message translates to:
  /// **'Sort asc'**
  String get sortAsc;

  /// No description provided for @sortByAmount.
  ///
  /// In en, this message translates to:
  /// **'Sort by amount'**
  String get sortByAmount;

  /// No description provided for @sortByDateTime.
  ///
  /// In en, this message translates to:
  /// **'Sort by datetime'**
  String get sortByDateTime;

  /// No description provided for @sortDesc.
  ///
  /// In en, this message translates to:
  /// **'Sort desc'**
  String get sortDesc;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get toDate;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @transactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Transaction amount'**
  String get transactionAmount;

  /// No description provided for @transactionAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter transaction amount...'**
  String get transactionAmountHint;

  /// No description provided for @transactionCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select transaction category'**
  String get transactionCategoryHint;

  /// No description provided for @transactionDeferredMonths.
  ///
  /// In en, this message translates to:
  /// **'Deferred months'**
  String get transactionDeferredMonths;

  /// No description provided for @transactionDeferredMonthsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter deferred months...'**
  String get transactionDeferredMonthsHint;

  /// No description provided for @transactionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get transactionDelete;

  /// No description provided for @transactionDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm to delete transaction {description}.'**
  String transactionDeleteConfirm(String description);

  /// No description provided for @transactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Transaction description'**
  String get transactionDescription;

  /// No description provided for @transactionDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter transaction description...'**
  String get transactionDescriptionHint;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @transactionsFilters.
  ///
  /// In en, this message translates to:
  /// **'Filter transactions'**
  String get transactionsFilters;

  /// No description provided for @transactionStatus.
  ///
  /// In en, this message translates to:
  /// **'Transaction status'**
  String get transactionStatus;

  /// No description provided for @transactionStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get transactionStatusCompleted;

  /// No description provided for @transactionStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Select transaction status'**
  String get transactionStatusHint;

  /// No description provided for @transactionStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get transactionStatusPending;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get transactionType;

  /// No description provided for @transactionTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionTypeIncome;

  /// No description provided for @transactionTypeIncomeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer income'**
  String get transactionTypeIncomeTransfer;

  /// No description provided for @transactionTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionTypeExpense;

  /// No description provided for @transactionTypeExpenseTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer expense'**
  String get transactionTypeExpenseTransfer;

  /// No description provided for @transactionTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select transaction type'**
  String get transactionTypeHint;

  /// No description provided for @transactionTypeWalletTransfer.
  ///
  /// In en, this message translates to:
  /// **' Wallet transfer'**
  String get transactionTypeWalletTransfer;

  /// No description provided for @transactionWalletHint.
  ///
  /// In en, this message translates to:
  /// **'Select transaction wallet'**
  String get transactionWalletHint;

  /// No description provided for @transactionWalletSourceHint.
  ///
  /// In en, this message translates to:
  /// **'Select source transaction wallet'**
  String get transactionWalletSourceHint;

  /// No description provided for @transactionWalletTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Select target transaction wallet'**
  String get transactionWalletTargetHint;

  /// No description provided for @transferFrom.
  ///
  /// In en, this message translates to:
  /// **'Transfer from {source}.'**
  String transferFrom(String source);

  /// No description provided for @transferTo.
  ///
  /// In en, this message translates to:
  /// **'Transfer to {target}.'**
  String transferTo(String target);

  /// No description provided for @userEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get userEmail;

  /// No description provided for @userEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email...'**
  String get userEmailHint;

  /// No description provided for @userPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get userPassword;

  /// No description provided for @userPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter password...'**
  String get userPasswordHint;

  /// No description provided for @userSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get userSignIn;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @walletDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete wallet'**
  String get walletDelete;

  /// No description provided for @walletDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm to delete wallet {name}.'**
  String walletDeleteConfirm(String name);

  /// No description provided for @walletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get walletName;

  /// No description provided for @walletNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter wallet name...'**
  String get walletNameHint;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @walletsBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallets balance'**
  String get walletsBalance;

  /// No description provided for @walletTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get walletTypeCash;

  /// No description provided for @walletTypeCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get walletTypeCreditCard;

  /// No description provided for @walletTypeDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit card'**
  String get walletTypeDebitCard;

  /// No description provided for @walletTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select wallet type'**
  String get walletTypeHint;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
  }

  throw FlutterError(
      'L10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
