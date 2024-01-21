package com.sp1ke.budgi.api.common;

import jakarta.validation.constraints.NotNull;
import java.util.Map;
import javax.annotation.Nullable;
import javax.annotation.OverridingMethodsMustInvokeSuper;
import lombok.Getter;

@Getter
public class ApiFilter<T> {
    private String search;

    @OverridingMethodsMustInvokeSuper
    protected void parseFromMap(@NotNull Map<String, String> map) {
        if (map.containsKey("search")) {
            search = map.get("search").trim();
        }
    }

    @OverridingMethodsMustInvokeSuper
    public boolean isEmpty() {
        return StringUtil.isBlank(search);
    }

    @Nullable
    public final String getSearchLike() {
        if (StringUtil.isNotBlank(search)) {
            return "%" + search.trim() + "%";
        }
        return null;
    }
}
