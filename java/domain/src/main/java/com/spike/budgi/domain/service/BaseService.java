package com.spike.budgi.domain.service;

import com.spike.budgi.domain.error.NotFoundException;
import com.spike.budgi.domain.jpa.JpaUser;
import com.spike.budgi.domain.model.User;
import com.spike.budgi.domain.repo.UserRepo;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public class BaseService {
    private final UserRepo userRepo;

    @NotNull
    JpaUser findUser(@NotNull User user) throws NotFoundException {
        return userRepo.findByCode(user.getCode()).orElseThrow(() -> new NotFoundException("User code is not valid."));
    }
}
