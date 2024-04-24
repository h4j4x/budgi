package com.spike.budgi.domain.jpa;

import com.spike.budgi.domain.Category;
import jakarta.persistence.Entity;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Entity
@Getter
@Setter
@SuperBuilder(toBuilder = true)
@Table(name = "categories", indexes = {
    @Index(name = "categories_code_UNQ", columnList = "code", unique = true),
})
public class JpaCategory extends JpaBase implements Category {
    private String label;

    private String description;
}
