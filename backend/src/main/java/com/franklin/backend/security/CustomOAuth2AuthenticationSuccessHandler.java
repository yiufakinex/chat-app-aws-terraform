package com.franklin.backend.security;

import java.io.IOException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import com.franklin.backend.entity.User;
import com.franklin.backend.entity.User.Role;
import com.franklin.backend.service.UserService;

@Component
public class CustomOAuth2AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    public static final String REDIRECT_URI_PARAM_COOKIE_NAME = "redirect_uri";

    @Autowired
    private UserService userService;

    @Value("${app.frontend.url}")
    private String frontendUrl;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
            Authentication authentication) throws IOException {
        try {
            CustomOAuth2User oAuthUser = (CustomOAuth2User) authentication.getPrincipal();
            User user = userService.currentUser(oAuthUser);

            logger.info("Authentication success. User role: " + user.getRole());
            String targetUrl;

            if (user.getRole().equals(Role.NEW_USER)) {
                targetUrl = frontendUrl + "/register";
            } else {
                targetUrl = frontendUrl + "/chat-app";
            }

            logger.info("Redirecting to: " + targetUrl);
            clearAuthenticationAttributes(request);
            getRedirectStrategy().sendRedirect(request, response, targetUrl);

        } catch (Exception e) {
            logger.error("Error in authentication success handler: ", e);
            response.sendRedirect(frontendUrl + "/login?error=" + e.getMessage());
        }
    }
}