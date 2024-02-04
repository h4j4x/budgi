package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.transaction.ApiTransaction;
import com.sp1ke.budgi.api.transaction.TransactionFilter;
import com.sp1ke.budgi.api.transaction.TransactionService;
import com.sp1ke.budgi.api.transaction.TransactionsStats;
import com.sp1ke.budgi.api.user.AuthUser;
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
public class TransactionController {
    private final TransactionService transactionService;

    @GetMapping("/stats")
    ResponseEntity<TransactionsStats> stats(@AuthenticationPrincipal AuthUser principal,
                                            @RequestParam Map<String, String> params) {
        var filter = TransactionFilter.parseMap(params);
        var stats = transactionService.stats(principal.userId(), filter);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/transaction")
    ResponseEntity<Page<ApiTransaction>> list(@AuthenticationPrincipal AuthUser principal,
                                              @SortDefault(sort = "updatedAt", direction = Sort.Direction.DESC) Pageable pageable,
                                              @RequestParam Map<String, String> params) {
        var filter = TransactionFilter.parseMap(params);
        var itemsPage = transactionService.fetch(principal.userId(), pageable, filter);
        return ResponseEntity.ok(itemsPage);
    }

    @PostMapping("/transaction")
    ResponseEntity<ApiTransaction> create(@AuthenticationPrincipal AuthUser principal,
                                          @RequestBody ApiTransaction transaction) {
        var apiTransaction = transactionService.save(principal.userId(), transaction, true);
        return ResponseEntity.status(201).body(apiTransaction);
    }

    @GetMapping("/transaction/{code}")
    ResponseEntity<ApiTransaction> getByCode(@AuthenticationPrincipal AuthUser principal,
                                             @PathVariable String code) {
        var apiTransaction = transactionService
            .findByCode(principal.userId(), code)
            .orElseThrow(() -> new HttpClientErrorException(HttpStatus.NOT_FOUND, "Transaction code is not valid"));
        return ResponseEntity.ok(apiTransaction);
    }

    @PutMapping("/transaction/{code}")
    ResponseEntity<ApiTransaction> updateByCode(@AuthenticationPrincipal AuthUser principal,
                                                @PathVariable String code,
                                                @RequestBody ApiTransaction transaction) {
        if (transaction.getCode() == null) {
            transaction.setCode(code);
        }
        var apiTransaction = transactionService.save(principal.userId(), transaction, false);
        return ResponseEntity.status(200).body(apiTransaction);
    }

    @DeleteMapping("/transaction/{code}")
    ResponseEntity<Void> deleteByCode(@AuthenticationPrincipal AuthUser principal,
                                      @PathVariable String code) {
        transactionService.deleteByCode(principal.userId(), code);
        return ResponseEntity.ok(null);
    }

    @DeleteMapping("/transaction/batch")
    ResponseEntity<Void> deleteByCodes(@AuthenticationPrincipal AuthUser principal,
                                       @RequestParam String codes) {
        transactionService.deleteByCodes(principal.userId(), codes.split(","));
        return ResponseEntity.ok(null);
    }
}
