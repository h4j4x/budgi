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
import jakarta.transaction.Transactional;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.util.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;

@Service
@RequiredArgsConstructor
public class JpaWalletService implements WalletService {
    private final WalletRepo walletRepo;

    private final Validator validator;

    @Override
    public Page<ApiWallet> fetch(@NotNull Long userId, @NotNull Pageable pageable,
                                 @Nullable WalletFilter filter) {
        var page = walletRepo.findAllByUserId(userId, pageable);
        return page.map(this::mapToApiWallet);
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
