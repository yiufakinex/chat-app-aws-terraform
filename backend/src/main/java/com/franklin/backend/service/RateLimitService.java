package com.franklin.backend.service;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import org.springframework.stereotype.Service;

@Service
public class RateLimitService {
    private final ConcurrentHashMap<String, AtomicInteger> requestCounts = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, Long> resetTimes = new ConcurrentHashMap<>();

    private static final int MAX_REQUESTS_PER_MINUTE_ANONYMOUS = 30000;
    private static final int MAX_REQUESTS_PER_MINUTE_AUTHENTICATED = 62000;

    public void checkRateLimit(String key, boolean isAuthenticated) {
        long now = System.currentTimeMillis();
        int limit = isAuthenticated ? MAX_REQUESTS_PER_MINUTE_AUTHENTICATED : MAX_REQUESTS_PER_MINUTE_ANONYMOUS;

        AtomicInteger counter = requestCounts.computeIfAbsent(key, k -> new AtomicInteger(0));
        Long resetTime = resetTimes.computeIfAbsent(key, k -> now + 60000);

        if (now > resetTime) {
            counter.set(0);
            resetTimes.put(key, now + 60000);
        }

        if (counter.incrementAndGet() > limit) {
            throw new RuntimeException("Too many requests");
        }
    }
}