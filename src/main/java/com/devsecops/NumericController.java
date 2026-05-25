package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.HtmlUtils;

@RestController
public class NumericController {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    @Value("${baseURL:http://node-pod:5000/plusone}")
    private String baseURL;

    @Value("${admin.secret.token:default_token}")
    private String adminSecretToken;

    RestTemplate restTemplate = new RestTemplate();

    @GetMapping("/")
    public String welcome() {
        return "<html><body>" +
                "<h1>Kubernetes DevSecOps</h1>" +
                "</body></html>";
    }

    @GetMapping("/admin-check")
    public String adminCheck() {
        // Assuming you want to verify the token in some way
        if ("expected_token".equals(adminSecretToken)) { // Replace with your actual verification logic
            return "Admin access verified";
        } else {
            return "Access denied";
        }
        
    }

    @GetMapping(value = "/check", produces = "text/html")
    public String check(@RequestParam(value = "name") String name) {
        return "<html><body><h1>Hello " + name + "</h1></body></html>";
        
    }

    @GetMapping("/compare/{value}")
    public String compareToFifty(@PathVariable int value) {
        String message = "Could not determine comparison";
        if (value > 50) {
            message = "Greater than 50";
        } else {
            message = "Smaller than or equal to 50";
        }
        return message;
    }

    @GetMapping("/increment/{value}")
    public ResponseEntity<String> increment(@PathVariable int value) {
        // Validate the input
        if (value < 0 || value > 100) {
            logger.warn("Invalid value for increment: " + value);
            return ResponseEntity.badRequest().body("Invalid value");
        }

        try {
            ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
            String response = responseEntity.getBody();
            logger.info("Value Received in Request - " + value);
            logger.info("Node Service Response - " + response);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.error("Error while incrementing value: " + value, e);
            return ResponseEntity.status(500).body("Internal Server Error");
        }
    }
}