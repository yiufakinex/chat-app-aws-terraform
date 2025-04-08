package com.franklin.backend.entity;

import java.util.HashSet;
import java.util.Set;
import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter
@Setter
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "\"user\"")
public class User {

    public enum AuthenticationProvider {
        GOOGLE, GITHUB, DISCORD
    }

    public enum Role {
        NEW_USER, USER, ADMIN, BANNED
    }

    public static final String USERNAME_SIZE_ERROR = "'username' should be between 3-30 characters.";
    public static final String USERNAME_PATTERN_ERROR = "'username' should only contain letters and numbers.";
    public static final String EMAIL_ERROR = "Invalid 'email'.";
    public static final String DISPLAY_NAME_ERROR = "'displayName' should be between 1-30 characters.";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "username", unique = true)
    @Size(min = 3, max = 30, message = USERNAME_SIZE_ERROR)
    @Pattern(regexp = "^[a-zA-Z0-9]*$", message = USERNAME_PATTERN_ERROR)
    private String username;

    @Column(name = "email", unique = true)
    @Email(message = EMAIL_ERROR)
    @NotBlank(message = EMAIL_ERROR)
    private String email;

    @Column(name = "display_name")
    @Size(min = 1, max = 30, message = DISPLAY_NAME_ERROR)
    @NotBlank(message = DISPLAY_NAME_ERROR)
    private String displayName;

    @Column(name = "avatar_url")
    private String avatarURL;

    @Column(name = "authentication_provider")
    @Enumerated(EnumType.STRING)
    private AuthenticationProvider authenticationProvider;

    @Column(name = "role")
    @Enumerated(EnumType.STRING)
    private Role role;

    @Column(name = "created_at")
    private Long createdAt;

    @ManyToMany(mappedBy = "users", fetch = FetchType.LAZY)
    @OrderBy("last_message_at DESC")
    @JsonIgnore
    private final Set<GroupChat> groupChats = new HashSet<>();

    @OneToMany(fetch = FetchType.LAZY, cascade = { CascadeType.PERSIST, CascadeType.MERGE }, mappedBy = "sender")
    @JsonIgnore
    private final Set<Message> messages = new HashSet<>();

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        } else if (!(o instanceof User)) {
            return false;
        }
        User other = (User) o;
        return this.id != null && id.equals(other.id);
    }

    @Override
    public int hashCode() {
        return id != null ? id.hashCode() : 0;
    }

}
