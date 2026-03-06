package com.devsecops;

import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
                .csrf().disable()
                .authorizeRequests()
                .antMatchers("/**").permitAll()
                .and()
                .headers()
                .xssProtection().disable() // Essential for ZAP to report 'High'
                .contentSecurityPolicy("script-src 'unsafe-inline'").and() // Allows XSS execution
                .frameOptions().disable();
    }
}