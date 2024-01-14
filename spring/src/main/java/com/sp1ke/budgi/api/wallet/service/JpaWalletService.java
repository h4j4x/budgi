package com.sp1ke.budgi.api.wallet.service;

import com.sp1ke.budgi.api.common.StringUtil;
import com.sp1ke.budgi.api.common.ValidatorUtil;
import com.sp1ke.budgi.api.wallet.ApiWallet;
import com.sp1ke.budgi.api.wallet.WalletService;
import com.sp1ke.budgi.api.wallet.domain.JpaWallet;
import com.sp1ke.budgi.api.wallet.repo.WalletRepo;
import jakarta.transaction.Transactional;
import jakarta.validation.Validator;
import jakarta.validation.constraints.NotNull;
import java.util.Optional;
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
    public Page<ApiWallet> fetch(Long userId, Pageable pageable) {
        var page = walletRepo.findAllByUserId(userId, pageable);
        return page.map(this::mapToApiWallet);
    }

    @Override
    public ApiWallet save(Long userId, ApiWallet data, boolean throwIfExists) {
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
    public Optional<ApiWallet> findByCode(Long userId, String code) {
        var wallet = walletRepo.findByUserIdAndCode(userId, code);
        return wallet.map(this::mapToApiWallet);
    }

    @Override
    @Transactional
    public void deleteByCode(Long userId, String code) {
        walletRepo.deleteByUserIdAndCode(userId, code);
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
