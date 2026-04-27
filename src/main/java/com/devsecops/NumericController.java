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
    
    // Use a safer alternative for HTTP requests if possible, e.g., Spring's WebClient
    RestTemplate restTemplate = new RestTemplate();

    @GetMapping("/")
    public String welcome() {
        return "<html><body>" +
                "<h1>Kubernetes DevSecOps</h1>" +
                "</body></html>";
    }

    @GetMapping("/admin-check")
    public ResponseEntity<String> adminCheck() {
        // Remove the hardcoded secret token
        return ResponseEntity.ok("Admin access verified");
    }

    @GetMapping(value = "/check", produces = "text/html")
    public String check(@RequestParam(value = "name") String name) {
        return "<html><body><h1>Hello " + HtmlUtils.htmlEscape(name) + "</h1></body></html>";
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
    public ResponseEntity<Integer> increment(@PathVariable int value) {
        // Validate the URL before making the request
        if (!isValidUrl(baseURL + '/' + value)) {
            logger.warn("Invalid URL: " + baseURL + '/' + value);
            return ResponseEntity.badRequest().body(null);
        }

        ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
        String response = responseEntity.getBody();
        logger.info("Value Received in Request - " + value);
        logger.info("Node Service Response - " + response);
        
        // Validate the response before parsing
        if (response == null || !response.matches("\\d+")) {
            logger.warn("Invalid response from node service: " + response);
            return ResponseEntity.badRequest().body(null);
        }

        return ResponseEntity.ok(Integer.parseInt(response));
    }

    private boolean isValidUrl(String url) {
        try {
            new java.net.URL(url).toURI();
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}