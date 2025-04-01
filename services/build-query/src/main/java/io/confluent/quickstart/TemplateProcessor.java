package io.confluent.quickstart;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class TemplateProcessor {
    public String processTemplate(String template) {
        String result = template;
        result = result.replace("${gcp-project-id}", System.getenv("GCP_PROJECT_ID"));
        result = result.replace("${bigquery-db}", System.getenv("BIGQUERY_DATABASE"));
        return result;
    }

    public String loadAndProcessTemplate(String templatePath) throws IOException, URISyntaxException {
        Path path = Paths.get(getClass().getClassLoader().getResource(templatePath).toURI());
        String template = Files.readString(path);
        return processTemplate(template);
    }
} 