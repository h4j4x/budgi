package com.sp1ke.budgi.api.data;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.Currency;

@Converter
public class CurrencyConverter implements AttributeConverter<Currency, String> {

    @Override
    public String convertToDatabaseColumn(Currency currency) {
        return currency.getCurrencyCode();
    }

    @Override
    public Currency convertToEntityAttribute(String currencyCode) {
        return Currency.getInstance(currencyCode);
    }
}
