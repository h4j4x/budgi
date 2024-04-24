package com.spike.budgi.domain.repo;

import com.spike.budgi.domain.jpa.JpaUser;
import java.util.Optional;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepo extends CrudRepository<JpaUser, Long> {
    Optional<JpaUser> findByCode(String code);
}
