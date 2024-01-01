package com.sp1ke.budgi.api.web;

import com.sp1ke.budgi.api.user.ApiToken;
import com.sp1ke.budgi.api.user.ApiUser;
import com.sp1ke.budgi.api.user.AuthService;
import com.sp1ke.budgi.api.user.TokenService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(
    value = "/auth",
    consumes = MediaType.APPLICATION_JSON_VALUE,
    produces = MediaType.APPLICATION_JSON_VALUE
)
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    private final TokenService tokenService;

    @PostMapping("/signup")
    public ResponseEntity<ApiToken> signup(@RequestBody ApiUser user) {
        var apiUser = authService.createUser(user);
        var token = tokenService.generateToken(apiUser);
        return ResponseEntity.status(201).body(token);
    }

    @PostMapping("/signin")
    public ResponseEntity<ApiToken> signin(@RequestBody ApiUser user) {
        var apiUser = authService.findUser(user);
        var token = tokenService.generateToken(apiUser);
        return ResponseEntity.ok(token);
    }

    @GetMapping("/me")
    public ResponseEntity<ApiUser> me(@AuthenticationPrincipal UserDetails principal) {
        var user = authService
            .findUser(principal.getUsername())
            .orElseThrow(() -> new UsernameNotFoundException("Username not found"));
        var apiUser = ApiUser.builder()
            .name(user.getName())
            .email(user.getEmail())
            .build();
        return ResponseEntity.ok(apiUser);
    }
}
