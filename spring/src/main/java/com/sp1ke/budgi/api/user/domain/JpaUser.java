package com.sp1ke.budgi.api.user.domain;

import com.sp1ke.budgi.api.data.JpaBase;
import com.sp1ke.budgi.api.user.AuthUser;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Entity
@Table(name = "users", indexes = {
    @Index(name = "users_email_UNQ", columnList = "email", unique = true),
})
@SuperBuilder
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaUser extends JpaBase implements AuthUser {
    @Email(message = "Valid user email is required")
    @NotNull(message = "Valid user email is required")
    @Column(length = 100, nullable = false)
    private String email;

    @Size(min = 2, max = 255, message = "Valid user name is required (2 to 255 characters)")
    @NotNull(message = "Valid user name is required (2 to 255 characters)")
    @Column(nullable = false)
    private String name;

    @Size(min = 3, max = 255, message = "Valid user password is required (3 to 255 characters)")
    @NotNull(message = "Valid user password is required (3 to 255 characters)")
    @Column(nullable = false)
    private String password;

    @Override
    public Long userId() {
        return getId();
    }

    @Override
    public String getUsername() {
        return email;
    }

    public void fixPassword(@NotNull PasswordEncoder passwordEncoder) {
        password = passwordEncoder.encode(password);
    }
}
