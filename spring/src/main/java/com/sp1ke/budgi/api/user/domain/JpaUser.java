package com.sp1ke.budgi.api.user.domain;

import com.sp1ke.budgi.api.user.AuthUser;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.OffsetDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.security.crypto.password.PasswordEncoder;

@Entity
@Table(name = "users", indexes = {
    @Index(name = "users_email_IDX", columnList = "email", unique = true)
})
@Builder
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaUser extends AuthUser {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(nullable = false)
    private Long id;

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

    @CreationTimestamp
    @Column(updatable = false, name = "created_at")
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @Override
    public Long userId() {
        return id;
    }

    @Override
    public String getUsername() {
        return email;
    }

    public void fixPassword(@NotNull PasswordEncoder passwordEncoder) {
        password = passwordEncoder.encode(password);
    }
}
