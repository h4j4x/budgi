package com.spike.budgi.domain.repo;

import com.spike.budgi.domain.jpa.JpaAccount;
import com.spike.budgi.domain.jpa.JpaUser;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.Optional;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AccountRepo extends CrudRepository<JpaAccount, Long> {
    Optional<JpaAccount> findByUserAndCode(@NotNull JpaUser user, @NotNull String code);

    List<JpaAccount> findByUser(@NotNull JpaUser jpaUser);
}
