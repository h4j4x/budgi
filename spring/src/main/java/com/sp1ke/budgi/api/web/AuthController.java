package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.user.*;
import com.sp1ke.budgi.api.web.annot.ApiController;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.client.HttpClientErrorException;

@ApiController
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    private final TokenService tokenService;

    @PostMapping("/auth/signup")
    ResponseEntity<ApiToken> signUp(@RequestBody ApiUser user) {
        var apiUser = authService.createUser(user);
        var token = tokenService.generateToken(apiUser);
        return ResponseEntity.status(201).body(token);
    }

    @PostMapping("/auth/signin")
    ResponseEntity<ApiToken> signIn(@RequestBody ApiUser user) {
        var apiUser = authService.findUser(user);
        var token = tokenService.generateToken(apiUser);
        return ResponseEntity.ok(token);
    }

    @GetMapping("/auth/me")
    ResponseEntity<ApiUser> me(@AuthenticationPrincipal AuthUser principal) {
        var user = authService
            .findUser(principal.getUsername())
            .orElseThrow(() -> new HttpClientErrorException(HttpStatus.NOT_FOUND, "Username not found"));
        var apiUser = ApiUser.builder()
            .name(user.getName())
            .email(user.getEmail())
            .build();
        return ResponseEntity.ok(apiUser);
    }
}
