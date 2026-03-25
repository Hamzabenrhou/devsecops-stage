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
                // Use lambdas to avoid "cannot find symbol" errors
                .csrf(csrf -> csrf.disable())
                .authorizeRequests(auth -> auth.antMatchers("/**").permitAll())
                .headers(headers -> headers.frameOptions(frame -> frame.disable()))
                .httpBasic(basic -> basic.disable())
                .formLogin(form -> form.disable());
    }
}