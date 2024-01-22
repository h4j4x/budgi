package com.sp1ke.budgi.api.transaction.service;

import com.sp1ke.budgi.api.category.CategoryService;
import com.sp1ke.budgi.api.common.ValidatorUtil;
import com.sp1ke.budgi.api.transaction.ApiTransaction;
import com.sp1ke.budgi.api.transaction.TransactionFilter;
import com.sp1ke.budgi.api.transaction.TransactionService;
import com.sp1ke.budgi.api.transaction.domain.JpaTransaction;
import com.sp1ke.budgi.api.transaction.repo.TransactionRepo;
import com.sp1ke.budgi.api.wallet.WalletService;
import jakarta.annotation.Nullable;
import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.transaction.Transactional;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
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
    private final TransactionRepo transactionRepo;

    private final Validator validator;

    private final CategoryService categoryService;

    private final WalletService walletService;

    private final EntityManager entityManager;

    @Override
    @NotNull
    public Page<ApiTransaction> fetch(@NotNull Long userId, @NotNull Pageable pageable,
                                      @Nullable TransactionFilter filter) {
        var page = fetchPage(userId, pageable, filter);
        var categoriesIdToCode = categoryService
            .fetchCodesOf(userId, page.get().map(JpaTransaction::getCategoryId).collect(Collectors.toSet()));
        var walletsIdToCode = walletService
            .fetchCodesOf(userId, page.get().map(JpaTransaction::getWalletId).collect(Collectors.toSet()));
        return page.map(transaction -> mapToApiTransaction(transaction, categoriesIdToCode, walletsIdToCode));
    }

    private Page<JpaTransaction> fetchPage(@NotNull Long userId, @NotNull Pageable pageable,
                                           @Nullable TransactionFilter filter) {
        if (filter == null || filter.isEmpty()) {
            return transactionRepo.findAllByUserId(userId, pageable);
        }

        var criteriaBuilder = entityManager.getCriteriaBuilder();
        var listQuery = criteriaBuilder.createQuery(JpaTransaction.class);
        var countQuery = criteriaBuilder.createQuery(Long.class);
        var root = listQuery.from(JpaTransaction.class);
        var listRoot = countQuery.from(JpaTransaction.class);

        listQuery
            .distinct(true)
            .where(where(criteriaBuilder, root, userId, filter))
            .orderBy(QueryUtils.toOrders(pageable.getSort(), root, criteriaBuilder));
        countQuery
            .select(criteriaBuilder.countDistinct(listRoot))
            .where(where(criteriaBuilder, listRoot, userId, filter));
        var list = entityManager.createQuery(listQuery)
            .setFirstResult(pageable.getPageNumber())
            .setMaxResults(pageable.getPageSize())
            .getResultList();
        var count = entityManager.createQuery(countQuery).getSingleResult();
        return new PageImpl<>(list, pageable, count);
    }

    private Predicate where(@NotNull CriteriaBuilder criteriaBuilder,
                            @NotNull Root<JpaTransaction> root,
                            @NotNull Long userId,
                            @NotNull TransactionFilter filter) {
        var where = criteriaBuilder.equal(root.get("userId"), userId);
        var searchLike = filter.getSearchLike();
        if (searchLike != null) {
            where = criteriaBuilder.and(where, criteriaBuilder.like(root.get("description"), searchLike));
        }
        if (filter.getTransactionTypes() != null && !filter.getTransactionTypes().isEmpty()) {
            var inClause = criteriaBuilder.in(root.get("transactionType"));
            for (var transactionType : filter.getTransactionTypes()) {
                inClause.value(transactionType);
            }
            where = criteriaBuilder.and(where, inClause);
        }
        return where;
    }

    @Override
    @NotNull
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

        transaction = transaction.toBuilder()
            .userId(userId)
            .code(data.getCode())
            .categoryId(categoryId)
            .walletId(walletId)
            .transactionType(data.getTransactionType())
            .amount(data.getAmount())
            .description(data.getDescription())
            .dateTime(data.getDateTime())
            .build();
        ValidatorUtil.validate(validator, transaction);

        transaction = transactionRepo.save(transaction);
        return mapToApiTransaction(transaction);
    }

    @Override
    public Optional<ApiTransaction> findByCode(@NotNull Long userId, @NotNull String code) {
        var transaction = transactionRepo.findByUserIdAndCode(userId, code);
        return transaction.map(this::mapToApiTransaction);
    }

    @Override
    @Transactional
    public void deleteByCode(@NotNull Long userId, @NotNull String code) {
        transactionRepo.deleteByUserIdAndCode(userId, code);
    }

    @Override
    @Transactional
    public void deleteByCodes(@NotNull Long userId, @NotNull String[] codes) {
        transactionRepo.deleteByUserIdAndCodeIn(userId, codes);
    }

    @NotNull
    private ApiTransaction mapToApiTransaction(@NotNull JpaTransaction transaction) {
        return mapToApiTransaction(transaction, null, null);
    }

    @NotNull
    private ApiTransaction mapToApiTransaction(@NotNull JpaTransaction transaction,
                                               @Nullable Map<Long, String> categoriesIdToCode,
                                               @Nullable Map<Long, String> walletsIdToCode) {
        return ApiTransaction.builder()
            .code(transaction.getCode())
            .categoryCode(categoryCode(transaction, categoriesIdToCode))
            .walletCode(walletCode(transaction, walletsIdToCode))
            .transactionType(transaction.getTransactionType())
            .currency(transaction.getCurrency())
            .amount(transaction.getAmount())
            .description(transaction.getDescription())
            .dateTime(transaction.getDateTime())
            .build();
    }

    @Nullable
    private String categoryCode(@NotNull JpaTransaction transaction,
                                @Nullable Map<Long, String> categoriesIdToCode) {
        if (categoriesIdToCode != null && categoriesIdToCode.containsKey(transaction.getCategoryId())) {
            return categoriesIdToCode.get(transaction.getCategoryId());
        }
        return categoryService.findCodeById(transaction.getUserId(), transaction.getCategoryId())
            .orElse(null);
    }

    @Nullable
    private String walletCode(@NotNull JpaTransaction transaction,
                              @Nullable Map<Long, String> walletsIdToCode) {
        if (walletsIdToCode != null && walletsIdToCode.containsKey(transaction.getWalletId())) {
            return walletsIdToCode.get(transaction.getWalletId());
        }
        return categoryService.findCodeById(transaction.getUserId(), transaction.getWalletId())
            .orElse(null);
    }
}