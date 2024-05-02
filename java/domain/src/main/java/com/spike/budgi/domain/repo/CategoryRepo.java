package com.spike.budgi.domain.repo;

import com.spike.budgi.domain.jpa.JpaCategory;
import com.spike.budgi.domain.jpa.JpaUser;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.Optional;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategoryRepo extends CrudRepository<JpaCategory, Long> {
    Optional<JpaCategory> findByUserAndCode(@NotNull JpaUser user, @NotNull String code);

    List<JpaCategory> findByUser(@NotNull JpaUser jpaUser);

    List<JpaCategory> findByUserAndCodeIn(@NotNull JpaUser user, @NotNull List<String> codes);
}
