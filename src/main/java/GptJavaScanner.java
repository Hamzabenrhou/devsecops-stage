//import java.io.*;
//import java.nio.file.*;
//import java.util.*;
//import okhttp3.*;
//import org.json.JSONArray;
//import org.json.JSONObject;
//
//public class GptJavaScanner {
//
//    private static final String API_KEY = System.getenv("openai-gptscan");
//    private static final String MODEL = "gpt-4o-mini"; // or gpt-4o
//
//    public static void main(String[] args) throws Exception {
//        List<Path> javaFiles = new ArrayList<>();
//        try (var paths = Files.walk(Paths.get("."))) {
//            paths.filter(p -> p.toString().endsWith(".java")).forEach(javaFiles::add);
//        }
//
//        if (javaFiles.isEmpty()) {
//            System.out.println("No Java files found.");
//            return;
//        }
//
//        StringBuilder report = new StringBuilder("# Java Code Scan Report\n\n");
//
//        for (Path file : javaFiles) {
//            System.out.println("Scanning " + file + "...");
//            String code = Files.readString(file);
//            String analysis = analyzeCodeWithGPT(code);
//            report.append("## ").append(file).append("\n").append(analysis).append("\n\n");
//        }
//
//        Files.writeString(Paths.get("gpt_java_report.md"), report.toString());
//        System.out.println("Report generated: gpt_java_report.md");
//    }
//
//    private static String analyzeCodeWithGPT(String code) throws IOException {
//        OkHttpClient client = new OkHttpClient();
//
//        JSONObject userMessage = new JSONObject();
//        userMessage.put("role", "user");
//        userMessage.put("content", "Analyze the following Java code for security issues, bugs, performance problems, and improvements:\n\n" + code);
//
//        JSONArray messages = new JSONArray();
//        messages.put(new JSONObject().put("role", "system").put("content", "You are an expert Java code reviewer."));
//        messages.put(userMessage);
//
//        JSONObject jsonBody = new JSONObject();
//        jsonBody.put("model", MODEL);
//        jsonBody.put("messages", messages);
//        jsonBody.put("temperature", 0);
//
//        RequestBody body = RequestBody.create(
//                jsonBody.toString(),
//                MediaType.parse("application/json")
//        );
//
//        Request request = new Request.Builder()
//                .url("https://api.openai.com/v1/chat/completions")
//                .header("Authorization", "Bearer " + API_KEY)
//                .post(body)
//                .build();
//
//        try (Response response = client.newCall(request).execute()) {
//            if (!response.isSuccessful()) {
//                throw new IOException("Unexpected code " + response);
//            }
//            JSONObject jsonResponse = new JSONObject(response.body().string());
//            return jsonResponse
//                    .getJSONArray("choices")
//                    .getJSONObject(0)
//                    .getJSONObject("message")
//                    .getString("content");
//        }
//    }
//}
//
