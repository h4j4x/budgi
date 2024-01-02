package com.sp1ke.budgi.api.category.repo;

import com.sp1ke.budgi.api.category.domain.JpaCategory;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryRepo extends CrudRepository<JpaCategory, Long> {
    Page<JpaCategory> findAllByUserId(Long userId, Pageable pageable);

    Optional<JpaCategory> findByUserIdAndCode(Long userId, String code);

    void deleteByUserIdAndCode(Long userId, String code);
}
