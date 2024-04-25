module budgi.domain {
    exports com.spike.budgi.domain.error;
    exports com.spike.budgi.domain.model;
    exports com.spike.budgi.domain.service;

    requires budgi.util;
    requires jakarta.persistence;
    requires jakarta.validation;
    requires static lombok;
    requires org.hibernate.orm.core;
    requires spring.context;
}