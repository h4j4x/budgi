package com.sp1ke.budgi.api.data;

import java.sql.SQLException;
import javax.sql.DataSource;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;

@Component
public class SchemaInitializer implements BeanPostProcessor {

    @Value("${spring.liquibase.default-schema}")
    private String schemaName;

    @Override
    public Object postProcessAfterInitialization(@NonNull Object bean, @NonNull String beanName) throws BeansException {
        if (bean instanceof DataSource dataSource) {
            try (var conn = dataSource.getConnection();
                 var statement = conn.createStatement()) {
                statement.execute(String.format("CREATE SCHEMA IF NOT EXISTS %s", schemaName));
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }
        return bean;
    }
}
