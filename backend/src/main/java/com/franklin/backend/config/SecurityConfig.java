package com.franklin.backend.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;

import com.franklin.backend.entity.User.Role;
import com.franklin.backend.security.CustomOAuth2AuthenticationFailureHandler;
import com.franklin.backend.security.CustomOAuth2AuthenticationSuccessHandler;
import com.franklin.backend.security.CustomOAuth2UserService;
import com.franklin.backend.security.HttpCookieOAuth2AuthorizationRequestRepository;
import com.franklin.backend.security.RateLimitFilter;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

        @Autowired
        private CustomOAuth2UserService customOAuth2UserService;

        @Autowired
        private CustomOAuth2AuthenticationSuccessHandler customOAuth2AuthenticationSuccessHandler;

        @Autowired
        private CustomOAuth2AuthenticationFailureHandler customOAuth2AuthenticationFailureHandler;

        @Autowired
        private RateLimitFilter rateLimitFilter;

        @Value("${app.frontend.url}")
        private String frontendUrl;

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
                http
                                .requiresChannel(channel -> channel
                                                .anyRequest().requiresSecure())
                                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                                .csrf(csrf -> csrf.disable())
                                .addFilterAfter(rateLimitFilter, BasicAuthenticationFilter.class)
                                .sessionManagement(session -> session
                                                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
                                .authorizeHttpRequests(auth -> {
                                        auth
                                                        // OAuth2 and login endpoints
                                                        .requestMatchers(
                                                                        "/oauth2/**",
                                                                        "/login",
                                                                        "/login/**",
                                                                        "/login/oauth2/code/*",
                                                                        "/oauth2/authorization/*",
                                                                        "/logout/**",
                                                                        "/error")
                                                        .permitAll()

                                                        // Public API endpoints
                                                        .requestMatchers(
                                                                        "/",
                                                                        "/built/**",
                                                                        "/api/login/**",
                                                                        "/api/users/search",
                                                                        "/register",
                                                                        "/api/login/user",
                                                                        "/api/login/principal")
                                                        .permitAll()

                                                        // Protected API endpoints
                                                        .requestMatchers(
                                                                        "/api/groupchat/**",
                                                                        "/api/message/**",
                                                                        "/api/users/**",
                                                                        "/api/**")
                                                        .hasAnyRole(Role.USER.toString(), Role.ADMIN.toString())

                                                        // All other requests need authentication
                                                        .anyRequest().authenticated();
                                })

                                // Configure OAuth2 login
                                .oauth2Login(oauth2 -> {
                                        oauth2
                                                        .authorizationEndpoint(authorization -> authorization
                                                                        .baseUri("/oauth2/authorization")
                                                                        .authorizationRequestRepository(
                                                                                        cookieAuthorizationRequestRepository()))
                                                        .redirectionEndpoint(redirection -> redirection
                                                                        .baseUri("/login/oauth2/code/*"))
                                                        .userInfoEndpoint(userInfo -> userInfo
                                                                        .userService(customOAuth2UserService))
                                                        .successHandler(customOAuth2AuthenticationSuccessHandler)
                                                        .failureHandler(customOAuth2AuthenticationFailureHandler);
                                })

                                // logout configuration
                                .logout(logout -> {
                                        logout
                                                        .logoutUrl("/api/logout")
                                                        .logoutSuccessUrl("/login")
                                                        .deleteCookies(
                                                                        "JSESSIONID",
                                                                        "XSRF-TOKEN",
                                                                        "remember-me",
                                                                        "OAuth2-Authorization-Request",

                                                                        "OAuth2-Authorization-State")
                                                        .clearAuthentication(true)
                                                        .invalidateHttpSession(true)
                                                        .permitAll()
                                                        .logoutSuccessHandler((request, response, authentication) -> {
                                                                response.setStatus(HttpStatus.OK.value());
                                                                response.setContentType("application/json");
                                                                response.getWriter().write(
                                                                                "{\"message\":\"Logged out successfully\"}");
                                                                response.getWriter().flush();
                                                        });
                                });

                return http.build();
        }

        @Bean
        public HttpCookieOAuth2AuthorizationRequestRepository cookieAuthorizationRequestRepository() {
                return new HttpCookieOAuth2AuthorizationRequestRepository();
        }

        @Bean
        CorsConfigurationSource corsConfigurationSource() {
                CorsConfiguration configuration = new CorsConfiguration();
                configuration.setAllowedOrigins(Arrays.asList(frontendUrl));
                configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
                configuration.setAllowedHeaders(Arrays.asList("*"));
                configuration.setAllowCredentials(true);
                configuration.setMaxAge(3600L);

                UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
                source.registerCorsConfiguration("/**", configuration);
                return source;
        }
}