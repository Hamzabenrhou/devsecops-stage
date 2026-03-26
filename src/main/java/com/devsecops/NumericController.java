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
	
	@Value("${baseURL}")
	private static final String baseURL;

	RestTemplate restTemplate = new RestTemplate();

	@GetMapping("/")
	public String welcome() {
		// Link helps the ZAP spider discover the vulnerable endpoint automatically
		return "<html><body>" +
				"<h1>Kubernetes DevSecOps</h1>" +
				
				"</body></html>";
	}
	@GetMapping("/admin-check")
	public String adminCheck() {
		String secretToken = System.getenv("ADMIN_SECRET_TOKEN");
		if (secretToken == null) {
			return "Admin access verification failed";
		}
		return "Admin access verified";
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
	public int increment(@PathVariable int value) {
		ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
		String response = responseEntity.getBody();
		logger.info("Value Received in Request - " + value);
		logger.info("Node Service Response - " + response);
		return Integer.parseInt(response);
	}
}

// Add these lines to your application.properties or application.yml
// baseURL=http://node-pod:5000/plusone
// ADMIN_SECRET_TOKEN=sqa_e4784435e3597732242ce9a699ce3d81f94e665f