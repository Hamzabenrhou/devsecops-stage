package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class NumericController {

	private final Logger logger = LoggerFactory.getLogger(getClass());
	private static final String baseURL = "http://node-pod:5000/plusone";

	RestTemplate restTemplate = new RestTemplate();

	@GetMapping("/")
	public String welcome() {
		// This link tells the ZAP spider: "Go here and test this parameter!"
		return "<html><body>" +
				"<h1>Kubernetes DevSecOps</h1>" +
				"<a href='/check?name=DevSecOpsUser'>Run Security Check</a>" +
				"</body></html>";
	}
	// --- THE PROBLEM START ---
	@GetMapping(value = "/check", produces = "text/html") // Force HTML header
	public String check(@RequestParam(value = "name") String name) {
		// Wrap it in HTML tags so ZAP sees it as a webpage, not a raw string
		return "<html><body><h1>Hello " + name + "</h1></body></html>";
	}
	// --- THE PROBLEM END ---

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
	public int increment(@PathVariable int value) {
		ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
		String response = responseEntity.getBody();
		logger.info("Value Received in Request - " + value);
		logger.info("Node Service Response - " + response);
		return Integer.parseInt(response);
	}
}