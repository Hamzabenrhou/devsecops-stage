package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.HtmlUtils;

@RestController
public class NumericController {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    @Value("${baseURL:http://node-pod:5000/plusone}")
    private String baseURL;

    private final RestTemplate restTemplate = new RestTemplate();

    @GetMapping("/")
    public String welcome() {
        return "<html><body>" +
                "<h1>Kubernetes DevSecOps</h1>" +
                "</body></html>";
    }

    @GetMapping("/admin-check")
    public ResponseEntity<String> adminCheck(@Value("${ADMIN_SECRET}") String secretToken) {
        if ("sqa_e4784435e3597732242ce9a699ce3d81f94e665f".equals(secretToken)) {
            return ResponseEntity.ok("Admin access verified");
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized access");
        }
    }

    @GetMapping(value = "/check", produces = "text/html")
    public String check(@RequestParam(value = "name") String name) {
        if (isNameValid(name)) {
            return "<html><body><h1>Hello " + HtmlUtils.htmlEscape(name) + "</h1></body></html>";
        } else {
            return "<html><body><h1>Invalid input</h1></body></html>";
        }
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
        try {
            ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
            String response = responseEntity.getBody();
            logger.info("Value Received in Request - " + value);
            logger.info("Node Service Response - " + response);
            return ResponseEntity.ok(Integer.parseInt(response));
        } catch (HttpStatusCodeException | ResourceAccessException e) {
            logger.error("Error calling external service: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    private boolean isNameValid(String name) {
        // Simple validation to ensure the name does not contain invalid characters
        return !name.matches("[^a-zA-Z ]+");
    }
}