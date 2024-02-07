package com.sp1ke.budgi.api.data.cache;

import org.springframework.data.redis.cache.RedisCache;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.cache.RedisCacheWriter;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;

public class RedisUserIdCacheManager extends RedisCacheManager {
    private final RedisConnectionFactory connectionFactory;

    public RedisUserIdCacheManager(RedisCacheConfiguration defaultCacheConfiguration,
                                   RedisConnectionFactory connectionFactory) {
        super(RedisCacheWriter.lockingRedisCacheWriter(connectionFactory), defaultCacheConfiguration);
        this.connectionFactory = connectionFactory;
    }

    @Override
    @NonNull
    protected RedisCache createRedisCache(@NonNull String name,
                                          @Nullable RedisCacheConfiguration cacheConfiguration) {
        var config = cacheConfiguration != null ? cacheConfiguration : getDefaultCacheConfiguration();
        return new RedisUserIdCache(name, getCacheWriter(), config, connectionFactory);
    }
}
