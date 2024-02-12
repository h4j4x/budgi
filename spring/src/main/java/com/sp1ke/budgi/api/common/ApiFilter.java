package com.sp1ke.budgi.api.common;

import jakarta.annotation.Nullable;
import jakarta.validation.constraints.NotNull;
import java.util.Arrays;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import javax.annotation.OverridingMethodsMustInvokeSuper;
import lombok.Getter;

@Getter
public class ApiFilter<T> {
    private String search;

    private Set<String> includingCodes;

    private Set<String> excludingCodes;

    @OverridingMethodsMustInvokeSuper
    protected void parseFromMap(@NotNull Map<String, String> map) {
        if (map.containsKey("search")) {
            search = map.get("search").trim();
        }
        if (map.containsKey("includingCodes")) {
            includingCodes = Arrays.stream(map.get("includingCodes").split(";"))
                .map(String::trim).collect(Collectors.toSet());
        }
        if (map.containsKey("excludingCodes")) {
            excludingCodes = Arrays.stream(map.get("excludingCodes").split(";"))
                .map(String::trim).collect(Collectors.toSet());
        }
    }

    @OverridingMethodsMustInvokeSuper
    public boolean isEmpty() {
        return StringUtil.isBlank(search) &&
            (includingCodes == null || includingCodes.isEmpty()) &&
            (excludingCodes == null || excludingCodes.isEmpty());
    }

    @Nullable
    public final String getSearchLike() {
        if (StringUtil.isNotBlank(search)) {
            return "%" + search.trim() + "%";
        }
        return null;
    }
}
