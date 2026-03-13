
package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
	private static final String baseURL = "http://node-pod:5000/plusone";

	RestTemplate restTemplate = new RestTemplate();

	@GetMapping("/")
	public String welcome() {
		// Link helps the ZAP spider discover the vulnerable endpoint automatically
		return "<html><body>" +
				"<h1>Kubernetes DevSecOps</h1>" +

				"</body></html>";
	}

	// --- FIXED CODE ---
	@GetMapping(value = "/check", produces = "text/html")
	public ResponseEntity<String> check(@RequestParam(value = "name") String name) {
		// 1. STRICT VALIDATION
		if (name == null || !name.matches("^[a-zA-Z0-9 ]{1,20}$")) {
			// Returning a 400 Bad Request tells ZAP: "I blocked this intentionally"
			return ResponseEntity.badRequest().body("<html><body><h1>Invalid Input</h1></body></html>");
		}

		// 2. ESCAPING
		String safeName = org.springframework.web.util.HtmlUtils.htmlEscape(name);
		return ResponseEntity.ok("<html><body><h1>Hello " + safeName + "</h1></body></html>");
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
	public int increment(@PathVariable int value) {
		ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
		String response = responseEntity.getBody();
		logger.info("Value Received in Request - " + value);
		logger.info("Node Service Response - " + response);
		return Integer.parseInt(response);
	}
}
