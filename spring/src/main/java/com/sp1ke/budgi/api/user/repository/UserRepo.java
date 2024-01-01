package com.sp1ke.budgi.api.user.repository;

import com.sp1ke.budgi.api.user.domain.JpaUser;
import java.util.Optional;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepo extends CrudRepository<JpaUser, Integer> {
    Optional<JpaUser> findByEmail(String email);
}
