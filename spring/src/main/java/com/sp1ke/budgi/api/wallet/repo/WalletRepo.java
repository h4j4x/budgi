package com.sp1ke.budgi.api.wallet.repo;

import com.sp1ke.budgi.api.wallet.domain.JpaWallet;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WalletRepo extends CrudRepository<JpaWallet, Long> {
    Page<JpaWallet> findAllByUserId(Long userId, Pageable pageable);

    Optional<JpaWallet> findByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCode(Long userId, String code);
}
