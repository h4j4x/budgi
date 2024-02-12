package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.user.AuthUser;
import com.sp1ke.budgi.api.wallet.ApiWallet;
import com.sp1ke.budgi.api.wallet.WalletFilter;
import com.sp1ke.budgi.api.wallet.WalletService;
import com.sp1ke.budgi.api.web.annot.ApiController;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.SortDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpClientErrorException;

@ApiController
@RequiredArgsConstructor
public class WalletController {
    private final WalletService walletService;

    @GetMapping("/wallet")
    ResponseEntity<Page<ApiWallet>> list(@AuthenticationPrincipal AuthUser principal,
                                         @SortDefault(sort = "updatedAt", direction = Sort.Direction.DESC) Pageable pageable,
                                         @RequestParam Map<String, String> params) {
        var filter = WalletFilter.parseMap(params);
        var itemsPage = walletService.fetch(principal.userId(), pageable, filter);
        return ResponseEntity.ok(itemsPage);
    }

    @PostMapping("/wallet")
    ResponseEntity<ApiWallet> create(@AuthenticationPrincipal AuthUser principal,
                                     @RequestBody ApiWallet wallet) {
        var ApiWallet = walletService.save(principal.userId(), wallet, true);
        return ResponseEntity.status(201).body(ApiWallet);
    }

    @GetMapping("/wallet/{code}")
    ResponseEntity<ApiWallet> getByCode(@AuthenticationPrincipal AuthUser principal,
                                        @PathVariable String code) {
        var ApiWallet = walletService
            .findByCode(principal.userId(), code)
            .orElseThrow(() -> new HttpClientErrorException(HttpStatus.NOT_FOUND, "Wallet code is not valid"));
        return ResponseEntity.ok(ApiWallet);
    }

    @PutMapping("/wallet/{code}")
    ResponseEntity<ApiWallet> updateByCode(@AuthenticationPrincipal AuthUser principal,
                                           @PathVariable String code,
                                           @RequestBody ApiWallet wallet) {
        if (wallet.getCode() == null) {
            wallet.setCode(code);
        }
        var ApiWallet = walletService.save(principal.userId(), wallet, false);
        return ResponseEntity.status(200).body(ApiWallet);
    }

    @DeleteMapping("/wallet/{code}")
    ResponseEntity<Void> deleteByCode(@AuthenticationPrincipal AuthUser principal,
                                      @PathVariable String code) {
        walletService.deleteByCode(principal.userId(), code);
        return ResponseEntity.ok(null);
    }

    @DeleteMapping("/wallet/batch")
    ResponseEntity<Void> deleteByCodes(@AuthenticationPrincipal AuthUser principal,
                                       @RequestParam String codes) {
        walletService.deleteByCodes(principal.userId(), codes.split(","));
        return ResponseEntity.ok(null);
    }
}
