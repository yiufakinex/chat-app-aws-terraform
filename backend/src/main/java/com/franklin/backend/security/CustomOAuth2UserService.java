package com.franklin.backend.security;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;

import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import com.franklin.backend.entity.User;
import com.franklin.backend.entity.User.AuthenticationProvider;
import com.franklin.backend.entity.User.Role;
import com.franklin.backend.exception.OAuth2AuthenticationProcessingException;
import com.franklin.backend.repository.UserRepository;
import com.franklin.backend.security.OAuth2UserInfo.OAuth2UserInfo;
import com.franklin.backend.security.OAuth2UserInfo.OAuth2UserInfoFactory;
import com.franklin.backend.util.DateFormat;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    @Autowired
    private UserRepository userRepository;

    private void validateOAuthProvider(String email, AuthenticationProvider currentProvider) {
        Optional<User> existingUser = userRepository.findByEmail(email);

        if (existingUser.isPresent()) {
            AuthenticationProvider existingProvider = existingUser.get().getAuthenticationProvider();
            if (existingProvider != currentProvider) {
                String errorMsg = String.format(
                        "Email %s is already registered with %s. Please use %s to login.",
                        email,
                        existingProvider,
                        existingProvider);
                throw new OAuth2AuthenticationProcessingException(errorMsg);
            }
        }
    }

    @Override
    public OAuth2User loadUser(OAuth2UserRequest request) throws OAuth2AuthenticationProcessingException {
        OAuth2User oAuth2User = super.loadUser(request);
        return processOAuth2User(request, oAuth2User);
    }

    private OAuth2User processOAuth2User(OAuth2UserRequest request, OAuth2User oAuth2User) {

        AuthenticationProvider currentProvider = AuthenticationProvider
                .valueOf(request.getClientRegistration().getRegistrationId().toUpperCase());
        OAuth2UserInfo userInfo = OAuth2UserInfoFactory.get(currentProvider, oAuth2User.getAttributes());

        String email = userInfo.getEmail();
        if (email == null || email.isBlank()) {
            String errorMsg = (currentProvider == AuthenticationProvider.GITHUB)
                    ? "No email found. Make sure your email is set to public on GitHub."
                    : "No email found from OAuth2 provider.";
            throw new OAuth2AuthenticationProcessingException(errorMsg);
        }

        validateOAuthProvider(email, currentProvider);

        Optional<User> userOptional = userRepository.findByEmail(email);
        return new CustomOAuth2User(
                userOptional.isPresent()
                        ? updateExistingUser(userOptional.get(), userInfo)
                        : registerNewUser(userInfo, currentProvider),
                oAuth2User.getAttributes());
    }

    private User registerNewUser(OAuth2UserInfo userInfo, AuthenticationProvider provider) {
        User user = User.builder()
                .authenticationProvider(provider)
                .email(userInfo.getEmail())
                .displayName(userInfo.getName() != null ? userInfo.getName() : "User")
                .avatarURL(userInfo.getAvatarURL())
                .role(Role.NEW_USER)
                .createdAt(DateFormat.getUnixTime())
                .build();
        return userRepository.save(user);
    }

    private User updateExistingUser(User user, OAuth2UserInfo userInfo) {
        user.setAvatarURL(userInfo.getAvatarURL());
        return userRepository.save(user);
    }
}
