package dev.syncclient.pling.executor.builtins;

import dev.syncclient.pling.executor.BuiltinExplorer;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class HttpBuiltins extends BuiltinExplorer {
    @Override
    public String description() {
        return "Some HTTP functions";
    }

    @BuiltinExplorerInfo(name = "http.get", description = "Gets the contents of a URL", usage = "#http.get [url] -> [result]")
    public Object get(String url) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();

        int responseCode = connection.getResponseCode();

        if (isSuccessful(responseCode)) {
            return readResponse(connection);
        } else {
            return "Error: " + responseCode;
        }
    }

    @BuiltinExplorerInfo(name = "http.post", description = "Posts data to a URL", usage = "#http.post [url] [body] -> [result]")
    public Object post(String url, String body) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
        connection.setRequestMethod("POST");
        connection.setDoOutput(true);

        connection.getOutputStream().write(body.getBytes());

        int responseCode = connection.getResponseCode();

        if (isSuccessful(responseCode)) {
            return readResponse(connection);
        } else {
            return "Error: " + responseCode;
        }
    }

    @BuiltinExplorerInfo(name = "http.put", description = "Puts data to a URL", usage = "#http.put [url] [body] -> [result]")
    public Object put(String url, String body) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
        connection.setRequestMethod("PUT");
        connection.setDoOutput(true);

        connection.getOutputStream().write(body.getBytes());

        int responseCode = connection.getResponseCode();

        if (isSuccessful(responseCode)) {
            return readResponse(connection);
        } else {
            return "Error: " + responseCode;
        }
    }

    @BuiltinExplorerInfo(name = "http.delete", description = "Deletes data from a URL", usage = "#http.delete [url] -> [result]")
    public Object delete(String url) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
        connection.setRequestMethod("DELETE");

        int responseCode = connection.getResponseCode();

        if (isSuccessful(responseCode)) {
            return readResponse(connection);
        } else {
            return "Error: " + responseCode;
        }
    }

    private boolean isSuccessful(int responseCode) {
        return responseCode >= 200 && responseCode < 300;
    }

    private String readResponse(HttpURLConnection connection) throws IOException {
        StringBuilder response = new StringBuilder();

        for (int c; (c = connection.getInputStream().read()) != -1; ) {
            response.append((char) c);
        }

        return response.toString();
    }
}
