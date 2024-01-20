package com.sp1ke.budgi.api.category.repo;

import com.sp1ke.budgi.api.category.domain.JpaCategory;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryRepo extends CrudRepository<JpaCategory, Long> {
    Page<JpaCategory> findAllByUserId(Long userId, Pageable pageable);

    Optional<JpaCategory> findByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCodeIn(Long userId, String[] codes);

    Optional<JpaCategory> findByUserIdAndId(Long userId, Long id);

    List<JpaCategory> findAllByUserIdAndIdIn(Long userId, Set<Long> ids);
}
