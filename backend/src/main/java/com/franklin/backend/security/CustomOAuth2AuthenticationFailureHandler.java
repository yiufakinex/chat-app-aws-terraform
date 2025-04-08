package com.franklin.backend.security;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class CustomOAuth2AuthenticationFailureHandler extends SimpleUrlAuthenticationFailureHandler {

    @Value("${app.frontend.url}")
    private String frontendUrl;

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
            AuthenticationException e) throws IOException, ServletException {

        String errorMessage = URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8.toString());

        String targetUrl = frontendUrl + "/login?error=" + errorMessage;

        System.out.println("Auth Error: " + e.getMessage());
        System.out.println("Redirecting to: " + targetUrl);

        response.setHeader("Access-Control-Allow-Origin", frontendUrl);
        response.setHeader("Access-Control-Allow-Credentials", "true");

        response.sendRedirect(targetUrl);
    }
}