package tn.esprit.devops;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${frontend.url:http://localhost:5173}")
    private String frontendUrl;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*") // Accepte toutes les origines (dev + prod)
                // Ou spécifiquement :
                // .allowedOrigins(
                //     "http://localhost:5173",
                //     "http://localhost:3000",
                //     frontendUrl
                // )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry
                .addResourceHandler("/**")
                .addResourceLocations("classpath:/static/");
    }

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addViewController("/{spring:[\\w-]+}")
                .setViewName("forward:/index.html");
        registry.addViewController("/{spring:[\\w-]+}/{spring2:[\\w-]+}")
                .setViewName("forward:/index.html");
        registry.addViewController("/{spring:[\\w-]+}/{spring2:[\\w-]+}/{spring3:[\\w-]+}")
                .setViewName("forward:/index.html");
    }
}