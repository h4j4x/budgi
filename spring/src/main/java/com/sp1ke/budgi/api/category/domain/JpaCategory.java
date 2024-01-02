package com.sp1ke.budgi.api.category.domain;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.OffsetDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "categories", uniqueConstraints = {
    @UniqueConstraint(name = "categories_user_id_code_UNQ", columnNames = "user_id, code")
})
@Builder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaCategory {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Size(min = 2, max = 100, message = "Valid category code is required (2 to 100 characters)")
    @NotNull(message = "Valid category code is required (2 to 100 characters)")
    @Column(length = 100, nullable = false)
    private String code;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Size(min = 2, max = 100, message = "Valid category name is required (2 to 255 characters)")
    @NotNull(message = "Valid category name is required (2 to 255 characters)")
    @Column(nullable = false)
    private String name;

    @CreationTimestamp
    @Column(updatable = false, name = "created_at")
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;
}
