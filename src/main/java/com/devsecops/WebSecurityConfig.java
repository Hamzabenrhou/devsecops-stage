package com.devsecops;

import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.headers().contentSecurityPolicy("script-src 'unsafe-inline'").and()
                .xssProtection().disable();
        http
                .csrf().disable()
                .authorizeRequests()
                .antMatchers("/**").permitAll() // Ensure ZAP can reach /check
                .and()
                .headers()
                .xssProtection().disable()      // DISABLE XSS Protection
                .contentSecurityPolicy("script-src 'unsafe-inline'").and() // Allow scripts
                .frameOptions().disable();      // Allow ZAP to wrap the page if needed
    }
}