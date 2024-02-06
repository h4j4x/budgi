package com.sp1ke.budgi.api.wallet.repo;

import com.sp1ke.budgi.api.wallet.domain.JpaWallet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WalletRepo extends CrudRepository<JpaWallet, Long> {
    Page<JpaWallet> findAllByUserId(Long userId, Pageable pageable);

    Optional<JpaWallet> findByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCodeIn(Long userId, String[] codes);

    Optional<JpaWallet> findByUserIdAndId(Long userId, Long id);

    List<JpaWallet> findAllByUserIdAndIdIn(Long userId, Set<Long> ids);

    List<JpaWallet> findAllByUserIdAndCodeIn(Long userId, Set<String> codes);
}
