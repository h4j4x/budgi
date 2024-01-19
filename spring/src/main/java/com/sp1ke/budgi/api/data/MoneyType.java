package com.sp1ke.budgi.api.data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Currency;
import java.util.Objects;
import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.metamodel.spi.ValueAccess;
import org.hibernate.usertype.CompositeUserType;
import org.joda.money.CurrencyUnit;
import org.joda.money.Money;

public class MoneyType implements CompositeUserType<Money> {
    @Override
    public Object getPropertyValue(Money money, int property) throws HibernateException {
        return (property == 0) ? money.getAmount() : money.getCurrencyUnit().toCurrency();
    }

    @Override
    public Money instantiate(ValueAccess values, SessionFactoryImplementor sessionFactory) {
        var amount = values.getValue(0, BigDecimal.class);
        var currency = values.getValue(1, Currency.class);
        return Money.of(CurrencyUnit.of(currency), amount);
    }

    @Override
    public Class<?> embeddable() {
        return MonetaryMapper.class;
    }

    @Override
    public Class<Money> returnedClass() {
        return Money.class;
    }

    @Override
    public boolean equals(Money value1, Money value2) {
        return Objects.equals(value1, value2);
    }

    @Override
    public int hashCode(Money value) {
        return value.hashCode();
    }

    @Override
    public Money deepCopy(Money value) {
        return Money.of(value.getCurrencyUnit(), value.getAmount());
    }

    @Override
    public boolean isMutable() {
        return false;
    }

    @Override
    public Serializable disassemble(Money value) {
        return value.toString();
    }

    @Override
    public Money assemble(Serializable cached, Object owner) {
        return Money.parse(cached.toString());
    }

    @Override
    public Money replace(Money detached, Money managed, Object owner) {
        return detached;
    }

    public static class MonetaryMapper {
        BigDecimal amount;

        Currency currency;
    }
}
