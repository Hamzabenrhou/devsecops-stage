
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
	public String check(@RequestParam(value = "name") String name) {
		// 1. STRICT ALLOW-LIST VALIDATION (Fixes File Inclusion Alert)
		// Only allow letters, numbers, and spaces. Reject everything else.
		if (name == null || !name.matches("^[a-zA-Z0-9 ]+$")) {
			return "<html><body><h1>Invalid Input Detected</h1>" +
					"<p>Only alphanumeric characters are allowed.</p></body></html>";
		}

		// 2. XSS ENCODING (You already have this)
		String safeName = HtmlUtils.htmlEscape(name);

		return "<html><body><h1>Hello " + safeName + "</h1></body></html>";
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
