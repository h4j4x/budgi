package com.spike.budgi.domain.jpa;

import com.spike.budgi.util.StringUtil;
import jakarta.persistence.*;
import jakarta.validation.constraints.Size;
import java.time.OffsetDateTime;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@AllArgsConstructor
@Getter
@MappedSuperclass
@NoArgsConstructor
@Setter
@SuperBuilder(toBuilder = true)
public abstract class JpaBase {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Size(max = 50, min = 2)
    @Column(length = 50, nullable = false)
    private String code;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @Builder.Default
    private boolean enabled = true;

    @PrePersist
    protected void prePersist() {
        if (StringUtil.isBlank(code)) {
            code = StringUtil.randomString(6);
        }
    }
}
