package com.spike.budgi.domain.jpa;

import com.spike.budgi.util.StringUtil;
import jakarta.persistence.*;
import jakarta.validation.constraints.Size;
import java.time.OffsetDateTime;
import javax.annotation.OverridingMethodsMustInvokeSuper;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@AllArgsConstructor
@Getter
@MappedSuperclass
@NoArgsConstructor
@SuperBuilder(toBuilder = true)
public abstract class JpaBase {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Size(min = 2, max = 50)
    @Column(length = 50, nullable = false)
    private String code;

    @CreationTimestamp
    @Column(updatable = false, name = "created_at")
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    private boolean enabled = true;

    @PrePersist
    @OverridingMethodsMustInvokeSuper
    protected void prePersist() {
        if (StringUtil.isBlank(code)) {
            code = StringUtil.randomString(6);
        }
    }
}
