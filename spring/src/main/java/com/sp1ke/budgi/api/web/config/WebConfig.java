package com.sp1ke.budgi.api.web.config;

import com.fasterxml.jackson.databind.Module;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.sp1ke.budgi.api.web.converter.MoneyDeserializer;
import com.sp1ke.budgi.api.web.converter.MoneySerializer;
import java.util.Arrays;
import java.util.stream.Stream;
import org.joda.money.Money;
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

    static final String[] API_POST_ANON_PATHS = new String[] {
        "/auth/signup", "/auth/signin"
    };

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http,
                                            AuthenticationProvider authProvider,
                                            JwtAuthFilter jwtAuthFilter) throws Exception {
        var authPaths = new String[] {
            "/auth/me", "/category/**", "/wallet/**", "/transaction/**"
        };
        var staticAnonPaths = new String[] {
            "/", "/*.css", "/*.png", "/*.webmanifest", "/manage/**"
        };
        http.csrf(AbstractHttpConfigurer::disable)
            .authorizeHttpRequests((registry) -> {
                    var apiAnonPaths = Arrays.stream(API_POST_ANON_PATHS)
                        .map(path -> REST_BASE_PATH + path)
                        .toArray(String[]::new);
                    var apiUserPaths = Stream.of(authPaths)
                        .map(path -> REST_BASE_PATH + path)
                        .toArray(String[]::new);
                    registry
                        .requestMatchers(HttpMethod.GET, staticAnonPaths).permitAll()
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
    public Module moneyJacksonModule() {
        var module = new SimpleModule();
        module.addDeserializer(Money.class, new MoneyDeserializer());
        module.addSerializer(Money.class, new MoneySerializer());
        return module;
    }
}
