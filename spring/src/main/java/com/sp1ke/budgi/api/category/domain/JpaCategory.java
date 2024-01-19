package com.sp1ke.budgi.api.category.domain;

import com.sp1ke.budgi.api.data.JpaUserBase;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "categories", indexes = {
    @Index(name = "categories_user_id_code_UNQ", columnList = "userId, code", unique = true),
})
@SuperBuilder(toBuilder = true)
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class JpaCategory extends JpaUserBase {
    @Size(min = 2, max = 100, message = "Valid category name is required (2 to 255 characters)")
    @NotNull(message = "Valid category name is required (2 to 255 characters)")
    @Column(nullable = false)
    private String name;
}
