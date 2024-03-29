package com.sp1ke.budgi.api.user.repo;

import com.sp1ke.budgi.api.user.domain.JpaUser;
import java.util.Optional;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepo extends CrudRepository<JpaUser, Long> {
    Optional<JpaUser> findByEmail(String email);
}
