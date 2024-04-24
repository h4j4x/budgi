package com.spike.budgi.domain.jpa;

import com.spike.budgi.domain.model.Category;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Getter
@NoArgsConstructor
@Setter
@SuperBuilder(toBuilder = true)
@Table(name = "categories", indexes = {
    @Index(name = "categories_user_id_code_UNQ", columnList = "user_id, code", unique = true),
})
public class JpaCategory extends JpaBase implements Category {
    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private JpaUser user;

    @Column(length = 100, nullable = false)
    @NotBlank(message = "Category label is required.")
    @Size(max = 100, min = 3, message = "Category label must have between 3 and 100 characters length.")
    private String label;

    @Column(length = 300)
    @Size(max = 300, message = "Category description must have 100 characters length maximum.")
    private String description;
}
