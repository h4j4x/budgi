package com.sp1ke.budgi.api.web.config;

import com.fasterxml.jackson.databind.Module;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.datatype.jsr310.ser.OffsetDateTimeSerializer;
import java.util.Arrays;
import java.util.stream.Stream;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class WebConfig {
    public static final String REST_BASE_PATH = "/api/v1";

    private static final String[] API_DOCS_PATHS = new String[] {"/docs", "/docs-ui"};

    private static final String[] API_POST_ANON_PATHS = new String[] {"/auth/signup", "/auth/signin"};

    static Stream<String> apiAnonPaths() {
        var builder = Stream.<String>builder();
        for (String value : API_DOCS_PATHS) {
            builder.add(value);
        }
        for (String value : API_POST_ANON_PATHS) {
            builder.add(value);
        }
        return builder.build();
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http,
                                            AuthenticationProvider authProvider,
                                            JwtAuthFilter jwtAuthFilter) throws Exception {
        var authPaths = new String[] {
            "/auth/me", "/category/**", "/category-budget/**", "/wallet/**", "/transaction/**"
        };
        var staticAnonPaths = new String[] {
            "/", "/*.css", "/*.png", "/*.webmanifest", "/manage/**"
        };
        http.csrf(AbstractHttpConfigurer::disable)
            .authorizeHttpRequests((registry) -> {
                    var apiDocsPaths = Arrays.stream(API_DOCS_PATHS)
                        .map(path -> REST_BASE_PATH + path)
                        .toArray(String[]::new);
                    var apiAnonPaths = Arrays.stream(API_POST_ANON_PATHS)
                        .map(path -> REST_BASE_PATH + path)
                        .toArray(String[]::new);
                    var apiUserPaths = Stream.of(authPaths)
                        .map(path -> REST_BASE_PATH + path)
                        .toArray(String[]::new);
                    registry
                        .requestMatchers(HttpMethod.GET, staticAnonPaths).permitAll()
                        .requestMatchers(HttpMethod.GET, apiDocsPaths).permitAll()
                        .requestMatchers(HttpMethod.POST, apiAnonPaths).permitAll()
                        .requestMatchers(apiUserPaths).authenticated();
                }
            )
            .sessionManagement((config) -> config.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authenticationProvider(authProvider)
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        var configuration = new CorsConfiguration();
        configuration.addAllowedOrigin("*");
        configuration.addAllowedMethod("*");
        configuration.addAllowedHeader("*");
        var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public Module javaTimeModule() {
        var module = new JavaTimeModule();
        module.addSerializer(OffsetDateTimeSerializer.INSTANCE);
        return module;
    }
}
