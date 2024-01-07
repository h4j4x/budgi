package com.sp1ke.budgi.api.web.annot;

import com.sp1ke.budgi.api.web.config.WebConfig;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@RestController
@RequestMapping(WebConfig.REST_BASE_PATH)
public @interface ApiController {
}
