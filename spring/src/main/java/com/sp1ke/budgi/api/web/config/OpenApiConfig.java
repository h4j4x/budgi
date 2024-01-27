package com.sp1ke.budgi.api.web.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import java.util.List;
import org.springframework.boot.autoconfigure.web.ServerProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI openAPI(ServerProperties serverProperties) {
        var protocol = serverProperties.getSsl() != null ? "https" : "http";
        var address = serverProperties.getAddress() != null ? serverProperties.getAddress().toString() : "127.0.0.1";
        var port = serverProperties.getPort() != null ? serverProperties.getPort() : 8080;
        return new OpenAPI()
            .info(new Info().title("Budgi API").version("0.0.1"))
            .servers(List.of(
                new Server().url(String.format("%s://%s:%d", protocol, address, port))
            ));
    }
}
