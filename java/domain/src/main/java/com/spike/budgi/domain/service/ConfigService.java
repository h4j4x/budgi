package com.spike.budgi.domain.service;

import java.util.Currency;
import org.springframework.stereotype.Service;

@Service
public class ConfigService {
    public Currency defaultCurrency() {
        return Currency.getInstance("USD");
    }
}
