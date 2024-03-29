package com.sp1ke.budgi.api.web.config;

import com.sp1ke.budgi.api.user.TokenService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.NotNull;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthFilter extends OncePerRequestFilter {
    private final TokenService tokenService;

    private final UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(
        @NonNull HttpServletRequest request,
        @NonNull HttpServletResponse response,
        @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        var requestURI = request.getRequestURI();
        if (requestURI.startsWith(WebConfig.REST_BASE_PATH)) {
            requestURI = requestURI.substring(WebConfig.REST_BASE_PATH.length());
            if (!isAnonPath(requestURI)) {
                var authToken = request.getHeader("Authorization");
                if (authToken != null) {
                    processAuthToken(request, authToken);
                }
            }
        }
        filterChain.doFilter(request, response);
    }

    private boolean isAnonPath(@NotNull String requestURI) {
        return WebConfig.apiAnonPaths().anyMatch(requestURI::startsWith);
    }

    private void processAuthToken(@NotNull HttpServletRequest request, @NotNull String token) {
        try {
            var username = tokenService.extractUsername(token);
            var userDetails = userDetailsService.loadUserByUsername(username);
            var authToken = new UsernamePasswordAuthenticationToken(
                userDetails, null, userDetails.getAuthorities());
            authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authToken);
        } catch (Exception e) {
            log.warn(e.getMessage());
        }
    }
}
