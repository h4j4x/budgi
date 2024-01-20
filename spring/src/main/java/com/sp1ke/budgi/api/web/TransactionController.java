package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.transaction.ApiTransaction;
import com.sp1ke.budgi.api.transaction.TransactionService;
import com.sp1ke.budgi.api.user.AuthUser;
import com.sp1ke.budgi.api.web.annot.ApiController;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.SortDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;

@ApiController
@RequiredArgsConstructor
public class TransactionController {
    private final TransactionService transactionService;

    @GetMapping("/transaction")
    ResponseEntity<Page<ApiTransaction>> list(@AuthenticationPrincipal AuthUser principal,
                                              @SortDefault(sort = "updatedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        var itemsPage = transactionService.fetch(principal.userId(), pageable);
        return ResponseEntity.ok(itemsPage);
    }
}
