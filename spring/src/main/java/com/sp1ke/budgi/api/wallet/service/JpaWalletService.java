package com.sp1ke.budgi.api.wallet.service;

import com.sp1ke.budgi.api.common.StringUtil;
import com.sp1ke.budgi.api.common.ValidatorUtil;
import com.sp1ke.budgi.api.data.JpaBase;
import com.sp1ke.budgi.api.wallet.ApiWallet;
import com.sp1ke.budgi.api.wallet.WalletFilter;
import com.sp1ke.budgi.api.wallet.WalletService;
import com.sp1ke.budgi.api.wallet.domain.JpaWallet;
import com.sp1ke.budgi.api.wallet.repo.WalletRepo;
import jakarta.annotation.Nullable;
import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.transaction.Transactional;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.util.*;
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
public class JpaWalletService implements WalletService {
    private final WalletRepo walletRepo;

    private final EntityManager entityManager;

    private final Validator validator;

    @Override
    @NotNull
    public Page<ApiWallet> fetch(@NotNull Long userId, @NotNull Pageable pageable,
                                 @Nullable WalletFilter filter) {
        var page = fetchPage(userId, pageable, filter);
        return page.map(this::mapToApiWallet);
    }

    private Page<JpaWallet> fetchPage(@NotNull Long userId, @NotNull Pageable pageable,
                                      @Nullable WalletFilter filter) {
        if (filter == null || filter.isEmpty()) {
            return walletRepo.findAllByUserId(userId, pageable);
        }

        var criteriaBuilder = entityManager.getCriteriaBuilder();
        var listQuery = criteriaBuilder.createQuery(JpaWallet.class);
        var countQuery = criteriaBuilder.createQuery(Long.class);
        var root = listQuery.from(JpaWallet.class);
        var listRoot = countQuery.from(JpaWallet.class);

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
                            @NotNull Root<JpaWallet> root,
                            @NotNull Long userId,
                            @NotNull WalletFilter filter) {
        var where = criteriaBuilder.equal(root.get("userId"), userId);
        var searchLike = filter.getSearchLike();
        if (searchLike != null) {
            var searchWhere = criteriaBuilder.like(root.get("code"), searchLike);
            searchWhere = criteriaBuilder.or(searchWhere, criteriaBuilder.like(root.get("name"), searchLike));
            where = criteriaBuilder.and(where, searchWhere);
        }
        if (filter.getIncludingCodes() != null && !filter.getIncludingCodes().isEmpty()) {
            var inClause = criteriaBuilder.in(root.get("code"));
            for (var includedCode : filter.getIncludingCodes()) {
                inClause.value(includedCode);
            }
            where = criteriaBuilder.and(where, inClause);
        }
        if (filter.getExcludingCodes() != null && !filter.getExcludingCodes().isEmpty()) {
            var inClause = criteriaBuilder.in(root.get("code"));
            for (var excludedCode : filter.getExcludingCodes()) {
                inClause.value(excludedCode);
            }
            where = criteriaBuilder.and(where, criteriaBuilder.not(inClause));
        }
        return where;
    }

    @Override
    public ApiWallet save(@NotNull Long userId, @NotNull ApiWallet data, boolean throwIfExists) {
        var code = StringUtil.isNotBlank(data.getCode()) ? data.getCode() : StringUtil.randomString(6);
        var wallet = walletRepo
            .findByUserIdAndCode(userId, code)
            .orElse(new JpaWallet());
        if (throwIfExists && wallet.getId() != null) {
            throw new HttpClientErrorException(HttpStatus.CONFLICT, "Wallet code already exists");
        }
        wallet = wallet.toBuilder()
            .userId(userId)
            .code(code)
            .name(data.getName())
            .walletType(data.getWalletType())
            .build();
        ValidatorUtil.validate(validator, wallet);

        wallet = walletRepo.save(wallet);
        return mapToApiWallet(wallet);
    }

    @Override
    public Optional<ApiWallet> findByCode(@NotNull Long userId, @NotNull String code) {
        var wallet = walletRepo.findByUserIdAndCode(userId, code);
        return wallet.map(this::mapToApiWallet);
    }

    @Override
    @Transactional
    public void deleteByCode(@NotNull Long userId, @NotNull String code) {
        walletRepo.deleteByUserIdAndCode(userId, code);
    }

    @Override
    @Transactional
    public void deleteByCodes(@NotNull Long userId, @NotNull String[] codes) {
        walletRepo.deleteByUserIdAndCodeIn(userId, codes);
    }

    @Override
    public Optional<Long> findIdByCode(@NotNull Long userId, @Nullable String code) {
        if (StringUtil.isNotBlank(code)) {
            return walletRepo.findByUserIdAndCode(userId, code)
                .map(JpaBase::getId);
        }
        return Optional.empty();
    }

    @Override
    public Map<Long, String> fetchCodesOf(@NotNull Long userId, @NotNull Set<Long> ids) {
        if (ids.isEmpty()) {
            return Collections.emptyMap();
        }
        var list = walletRepo.findAllByUserIdAndIdIn(userId, ids);
        var map = new HashMap<Long, String>();
        for (var wallet : list) {
            map.put(wallet.getId(), wallet.getCode());
        }
        return map;
    }

    @Override
    public Optional<String> findCodeById(@NotNull Long userId, @NotNull Long id) {
        return walletRepo.findByUserIdAndId(userId, id)
            .map(JpaBase::getCode);
    }

    @Override
    public List<ApiWallet> findAllByUserIdAndCodesIn(Long userId, Set<String> codes) {
        return walletRepo.findAllByUserIdAndCodeIn(userId, codes).stream()
            .map(this::mapToApiWallet).toList();
    }

    @NotNull
    private ApiWallet mapToApiWallet(@NotNull JpaWallet wallet) {
        return ApiWallet.builder()
            .code(wallet.getCode())
            .name(wallet.getName())
            .walletType(wallet.getWalletType())
            .build();
    }
}
