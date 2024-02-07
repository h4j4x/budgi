package com.sp1ke.budgi.api.data.cache;

import org.springframework.data.redis.cache.RedisCache;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheWriter;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.KeyScanOptions;
import org.springframework.lang.NonNull;

public class RedisUserIdCache extends RedisCache {
    private final RedisConnectionFactory connectionFactory;

    public RedisUserIdCache(String name, RedisCacheWriter cacheWriter,
                            RedisCacheConfiguration cacheConfiguration,
                            RedisConnectionFactory connectionFactory) {
        super(name, cacheWriter, cacheConfiguration);
        this.connectionFactory = connectionFactory;
    }

    @Override
    public void evict(@NonNull Object key) {
        super.evict(key);
        try (var connection = connectionFactory.getConnection()) {
            var pattern = getName() + "::\\[" + convertKey(key) + "\\,*";
            var scanOptions = KeyScanOptions.scanOptions().match(pattern).build();
            try (var cursor = connection.keyCommands().scan(scanOptions)) {
                while (cursor.hasNext()) {
                    connection.keyCommands().del(cursor.next());
                }
            }
        }
    }
}
