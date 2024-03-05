package com.sp1ke.budgi.api.transaction.service;

import com.sp1ke.budgi.api.category.ApiCategory;
import com.sp1ke.budgi.api.category.ApiCategoryBudget;
import com.sp1ke.budgi.api.category.CategoryBudgetService;
import com.sp1ke.budgi.api.category.CategoryService;
import com.sp1ke.budgi.api.common.DateTimeUtil;
import com.sp1ke.budgi.api.common.SavedTransactionEvent;
import com.sp1ke.budgi.api.common.ValidatorUtil;
import com.sp1ke.budgi.api.transaction.*;
import com.sp1ke.budgi.api.transaction.domain.JpaTransaction;
import com.sp1ke.budgi.api.transaction.model.IdAmount;
import com.sp1ke.budgi.api.transaction.repo.TransactionRepo;
import com.sp1ke.budgi.api.wallet.ApiWallet;
import com.sp1ke.budgi.api.wallet.WalletService;
import jakarta.annotation.Nullable;
import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.transaction.Transactional;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.query.QueryUtils;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;

@Service
@RequiredArgsConstructor
public class JpaTransactionService implements TransactionService {
    private static final String CACHE_TRANSACTION_STATS_NAME = "transactions-stats";

    private final TransactionRepo transactionRepo;

    private final Validator validator;

    private final CategoryService categoryService;

    private final CategoryBudgetService categoryBudgetService;

    private final WalletService walletService;

    private final EntityManager entityManager;

    private final ApplicationEventPublisher eventPublisher;

    @Override
    @NotNull
    public Page<ApiTransaction> fetch(@NotNull Long userId, @NotNull Pageable pageable,
                                      @Nullable TransactionFilter filter) {
        var page = fetchPage(userId, pageable, filter);
        var categoriesIdMap = categoryService
            .findAllByIds(userId, page.get().map(JpaTransaction::getCategoryId).collect(Collectors.toSet()));
        var walletsIdMap = walletService
            .findAllByIds(userId, page.get().map(JpaTransaction::getWalletId).collect(Collectors.toSet()));
        return page.map(transaction -> mapToApiTransaction(transaction, categoriesIdMap, walletsIdMap));
    }

    @Override
    @NotNull
    public Long count(@NotNull Long userId, @Nullable TransactionFilter filter) {
        if (filter == null || filter.isEmpty()) {
            return transactionRepo.countByUserId(userId);
        }

        var criteriaBuilder = entityManager.getCriteriaBuilder();
        var countQuery = criteriaBuilder.createQuery(Long.class);
        var countRoot = countQuery.from(JpaTransaction.class);
        countQuery
            .select(criteriaBuilder.countDistinct(countRoot))
            .where(where(criteriaBuilder, countRoot, userId, filter));

        return entityManager.createQuery(countQuery).getSingleResult();
    }

    private Page<JpaTransaction> fetchPage(@NotNull Long userId, @NotNull Pageable pageable,
                                           @Nullable TransactionFilter filter) {
        if (filter == null || filter.isEmpty()) {
            return transactionRepo.findAllByUserId(userId, pageable);
        }

        var criteriaBuilder = entityManager.getCriteriaBuilder();
        var listQuery = criteriaBuilder.createQuery(JpaTransaction.class);
        var root = listQuery.from(JpaTransaction.class);

        listQuery
            .distinct(true)
            .where(where(criteriaBuilder, root, userId, filter))
            .orderBy(QueryUtils.toOrders(pageable.getSort(), root, criteriaBuilder));
        var list = entityManager.createQuery(listQuery)
            .setFirstResult(pageable.getPageNumber())
            .setMaxResults(pageable.getPageSize())
            .getResultList();
        var count = count(userId, filter);
        return new PageImpl<>(list, pageable, count);
    }

    private Predicate where(@NotNull CriteriaBuilder criteriaBuilder,
                            @NotNull Root<JpaTransaction> root,
                            @NotNull Long userId,
                            @NotNull TransactionFilter filter) {
        var where = criteriaBuilder.equal(root.get("userId"), userId);
        var searchLike = filter.getSearchLike();
        if (searchLike != null) {
            var searchWhere = criteriaBuilder.like(root.get("description"), searchLike);
            where = criteriaBuilder.and(where, searchWhere);
        }
        if (filter.getTransactionTypes() != null && !filter.getTransactionTypes().isEmpty()) {
            var inClause = criteriaBuilder.in(root.get("transactionType"));
            for (var transactionType : filter.getTransactionTypes()) {
                inClause.value(transactionType);
            }
            where = criteriaBuilder.and(where, inClause);
        }
        if (filter.getTransactionStatuses() != null && !filter.getTransactionStatuses().isEmpty()) {
            var inClause = criteriaBuilder.in(root.get("transactionStatus"));
            for (var transactionStatus : filter.getTransactionStatuses()) {
                inClause.value(transactionStatus);
            }
            where = criteriaBuilder.and(where, inClause);
        }
        var categoryId = categoryService.findIdByCode(userId, filter.getCategoryCode());
        if (categoryId.isPresent()) {
            var categoryWhere = criteriaBuilder.equal(root.get("categoryId"), categoryId.get());
            where = criteriaBuilder.and(where, categoryWhere);
        }
        var walletId = walletService.findIdByCode(userId, filter.getWalletCode());
        if (walletId.isPresent()) {
            var walletWhere = criteriaBuilder.equal(root.get("walletId"), walletId.get());
            where = criteriaBuilder.and(where, walletWhere);
        }
        if (filter.getFrom() != null) {
            var fromWhere = criteriaBuilder.greaterThanOrEqualTo(root.get("dateTime"), filter.getFrom());
            where = criteriaBuilder.and(where, fromWhere);
        }
        if (filter.getTo() != null) {
            var toWhere = criteriaBuilder.lessThanOrEqualTo(root.get("dateTime"), filter.getTo());
            where = criteriaBuilder.and(where, toWhere);
        }
        return where;
    }

    @Override
    @NotNull
    @Transactional
    @CacheEvict(value = CACHE_TRANSACTION_STATS_NAME, key = "#userId")
    public ApiTransaction save(@NotNull Long userId, @NotNull ApiTransaction data, boolean throwIfExists) {
        var transaction = transactionRepo
            .findByUserIdAndCode(userId, data.getCode())
            .orElse(new JpaTransaction());
        if (throwIfExists && transaction.getId() != null) {
            throw new HttpClientErrorException(HttpStatus.CONFLICT, "Transaction code already exists");
        }

        var categoryId = categoryService.findIdByCode(userId, data.getCategoryCode())
            .orElseThrow(() -> new HttpClientErrorException(HttpStatus.BAD_REQUEST, "Invalid category"));
        var walletId = walletService.findIdByCode(userId, data.getWalletCode())
            .orElseThrow(() -> new HttpClientErrorException(HttpStatus.BAD_REQUEST, "Invalid wallet"));

        var previousAmount = transaction.getSignedAmount().negate();
        transaction = transaction.toBuilder()
            .userId(userId)
            .code(data.getCode())
            .categoryId(categoryId)
            .walletId(walletId)
            .currency(data.getCurrency())
            .transactionType(data.getTransactionType())
            .transactionStatus(data.getTransactionStatus())
            .amount(data.getAmount())
            .description(data.getDescription())
            .dateTime(data.getDateTime())
            .build();
        ValidatorUtil.validate(validator, transaction);

        transaction = transactionRepo.save(transaction);
        var apiTransaction = mapToApiTransaction(transaction);
        var newAmount = transaction.getSignedAmount();
        var event = new SavedTransactionEvent(userId, data.getWalletCode(),
            transaction.getCurrency(), transaction.getDateTime(), previousAmount, newAmount);
        eventPublisher.publishEvent(event);
        return apiTransaction;
    }

    @Override
    public Optional<ApiTransaction> findByCode(@NotNull Long userId, @NotNull String code) {
        var transaction = transactionRepo.findByUserIdAndCode(userId, code);
        return transaction.map(this::mapToApiTransaction);
    }

    @Override
    @Transactional
    @CacheEvict(value = CACHE_TRANSACTION_STATS_NAME, key = "#userId")
    public void deleteByCode(@NotNull Long userId, @NotNull String code) {
        transactionRepo.deleteByUserIdAndCode(userId, code);
    }

    @Override
    @Transactional
    @CacheEvict(value = CACHE_TRANSACTION_STATS_NAME, key = "#userId")
    public void deleteByCodes(@NotNull Long userId, @NotNull String[] codes) {
        transactionRepo.deleteByUserIdAndCodeIn(userId, codes);
    }

    @NotNull
    private ApiTransaction mapToApiTransaction(@NotNull JpaTransaction transaction) {
        return mapToApiTransaction(transaction, null, null);
    }

    @Override
    @NotNull
    @Cacheable(value = CACHE_TRANSACTION_STATS_NAME, key = "{" + "#userId" + ",#filter}")
    public TransactionsStats stats(@NotNull Long userId, @NotNull TransactionFilter filter) {
        if (filter.hasInvalidDates()) {
            throw new HttpClientErrorException(HttpStatus.BAD_REQUEST, "Invalid dates");
        }
        var from = DateTimeUtil.localDateToOffsetDateTime(filter.getFrom());
        var to = DateTimeUtil.localDateToOffsetDateTime(filter.getTo().plusDays(1));

        var income = transactionRepo.sumAmountByUserIdAndDatesAndTransactionType(
            userId, from, to, TransactionType.INCOME);
        var categoryBudget = categoryBudgetService
            .categoryBudgets(userId, from, to)
            .stream().collect(Collectors.toMap(ApiCategoryBudget::getCategoryCode, ApiCategoryBudget::getAmount));
        var expense = fetchCategoriesExpenses(userId, from, to);
        var balance = fetchWalletsBalances(userId, from, to);

        var categoriesCodes = new HashSet<>(categoryBudget.keySet());
        categoriesCodes.addAll(expense.keySet());
        var categories = categoryService
            .findAllByUserIdAndCodesIn(userId, categoriesCodes)
            .stream().collect(Collectors.toMap(ApiCategory::getCode, Function.identity()));
        var wallets = walletService
            .findAllByUserIdAndCodesIn(userId, balance.keySet())
            .stream().collect(Collectors.toMap(ApiWallet::getCode, Function.identity()));

        return TransactionsStats.builder()
            .from(filter.getFrom())
            .to(filter.getTo())
            .income(income)
            .categoryBudget(categoryBudget)
            .categoryExpense(expense)
            .walletBalance(balance)
            .categories(categories)
            .wallets(wallets)
            .build();
    }

    private Map<String, BigDecimal> fetchCategoriesExpenses(@NotNull Long userId,
                                                            @NotNull OffsetDateTime from,
                                                            @NotNull OffsetDateTime to) {
        var categoriesExpenses = transactionRepo.sumByUserIdAndDatesAndTransactionTypeGroupByCategories(
            userId, from, to, TransactionType.EXPENSE);
        var categoriesIds = categoriesExpenses.stream().map(IdAmount::getId).collect(Collectors.toSet());
        var categories = categoryService.findAllByIds(userId, categoriesIds);
        return categoriesExpenses.stream().collect(Collectors
            .toMap(idAmount -> categories.get(idAmount.getId()).getCode(), IdAmount::getAmount));
    }

    private Map<String, BigDecimal> fetchWalletsBalances(@NotNull Long userId,
                                                         @NotNull OffsetDateTime from,
                                                         @NotNull OffsetDateTime to) {
        var transactions = transactionRepo.findAllByUserIdAndDateTimeBetween(userId, from, to);
        var walletsIds = transactions.stream().map(JpaTransaction::getWalletId).collect(Collectors.toSet());
        var wallets = walletService.findAllByIds(userId, walletsIds);
        var map = new HashMap<String, BigDecimal>();
        transactions.forEach(transaction -> {
            var code = wallets.get(transaction.getWalletId()).getCode();
            var balance = map.getOrDefault(code, BigDecimal.ZERO);
            balance = balance.add(transaction.getSignedAmount());
            map.put(code, balance);
        });
        return map;
    }

    @NotNull
    private ApiTransaction mapToApiTransaction(@NotNull JpaTransaction transaction,
                                               @Nullable Map<Long, ApiCategory> categoriesIdMap,
                                               @Nullable Map<Long, ApiWallet> walletsIdMap) {
        var category = categoryOf(transaction, categoriesIdMap);
        var wallet = walletOf(transaction, walletsIdMap);
        return ApiTransaction.builder()
            .code(transaction.getCode())
            .categoryCode(category != null ? category.getCode() : null)
            .category(category)
            .walletCode(wallet != null ? wallet.getCode() : null)
            .wallet(wallet)
            .transactionType(transaction.getTransactionType())
            .transactionStatus(transaction.getTransactionStatus())
            .currency(transaction.getCurrency())
            .amount(transaction.getAmount())
            .description(transaction.getDescription())
            .dateTime(transaction.getDateTime())
            .build();
    }

    @Nullable
    private ApiCategory categoryOf(@NotNull JpaTransaction transaction,
                                   @Nullable Map<Long, ApiCategory> categoriesIdsMap) {
        if (categoriesIdsMap != null && categoriesIdsMap.containsKey(transaction.getCategoryId())) {
            return categoriesIdsMap.get(transaction.getCategoryId());
        }
        return categoryService.findById(transaction.getUserId(), transaction.getCategoryId())
            .orElse(null);
    }

    @Nullable
    private ApiWallet walletOf(@NotNull JpaTransaction transaction,
                               @Nullable Map<Long, ApiWallet> walletsIdMap) {
        if (walletsIdMap != null && walletsIdMap.containsKey(transaction.getWalletId())) {
            return walletsIdMap.get(transaction.getWalletId());
        }
        return walletService.findById(transaction.getUserId(), transaction.getWalletId())
            .orElse(null);
    }
}
