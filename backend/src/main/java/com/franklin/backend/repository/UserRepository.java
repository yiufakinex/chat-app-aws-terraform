package com.franklin.backend.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.franklin.backend.entity.User;
import com.franklin.backend.entity.User.AuthenticationProvider;;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @Query("SELECT u.authenticationProvider FROM User u WHERE u.email = :email")
    Optional<AuthenticationProvider> findProviderByEmail(String email);

    @Query("SELECT u from User u LEFT JOIN FETCH u.groupChats WHERE u.username = :username")
    Optional<User> findUserJoinedWithGroupChat(String username);

    Optional<User> findByUsername(String username);

    Optional<User> findByEmail(String email);

    Boolean existsByUsername(String username);

    Boolean existsByEmail(String email);

}
