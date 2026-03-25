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
                // Enable CSRF protection by default
                .csrf() 

                // 1. Allow all traffic so ZAP doesn't get a 403 Forbidden
                .authorizeRequests()
                .antMatchers("/**").permitAll()
                .and()

                // Configure CSRF protection settings if needed (e.g., custom token parameter name)
                .csrf().tokenParameterName("_csrf").parameterName("_csrf")

                // 2. Disable the "Security Gates" that lower the ZAP Risk score
                .headers()
                // This is the most important line:
                // If enabled, ZAP sees the 'X-XSS-Protection' header and says "Risk: Low"
                // because the browser blocks it. We want "Risk: High".
                .xssProtection().disable()

                // Allow ZAP to execute its test scripts in the browser response
                .contentSecurityPolicy("script-src 'unsafe-inline'").and()

                // Disable Frame Options so ZAP's HUD or reports can wrap the app
                .frameOptions().disable()
                .and()

                // 3. Disable standard auth to keep the path clear
                .httpBasic().disable()
                .formLogin().disable();
    }
}