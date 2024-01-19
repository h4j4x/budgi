package com.sp1ke.budgi.api.data;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@MappedSuperclass
@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public abstract class JpaUserBase extends JpaBase {
    @Column(name = "user_id", nullable = false)
    private Long userId;
}
