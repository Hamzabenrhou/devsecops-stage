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
            .authorizeRequests()
                .antMatchers("/**").authenticated() // Ensure that all endpoints are authenticated
                .and()

            .csrf().requireCsrfProtectionOnFormSubmission() // Enable CSRF protection for form submissions
                .and()

            .headers()
                .xssProtection().disable()
                .contentSecurityPolicy("script-src 'unsafe-inline'") // Keep Content Security Policy if needed
                .frameOptions().disable()
                .and()

            .httpBasic()
                .and()

            .formLogin();
    }
}