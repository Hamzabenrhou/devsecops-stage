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
                
                .csrf().disable()
                .authorizeRequests()
                .antMatchers("/**").permitAll()
                .and()



                .headers()

                .xssProtection().disable()


                .contentSecurityPolicy("script-src 'unsafe-inline'").and()


                .frameOptions().disable()
                .and()


                .httpBasic().disable()
                .formLogin().disable();
    }
}