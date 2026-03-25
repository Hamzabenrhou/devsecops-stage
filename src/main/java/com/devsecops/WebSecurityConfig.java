package com.devsecops;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
                // 1. Properly Enable CSRF (Using the correct Spring Security 5.x syntax)
                .csrf()
                .and()

                // 2. Require Authentication for everything
                .authorizeRequests()
                .anyRequest().authenticated()
                .and()

                // 3. Enable Security Headers (XSS and Frame Options)
                .headers()
                .xssProtection()
                .and()
                .frameOptions().deny() // Prevents clickjacking
                .contentSecurityPolicy("script-src 'self'") // Stricter CSP for production
                .and()
                .and()

                // 4. Standard Authentication
                .httpBasic()
                .and()
                .formLogin();
    }
}