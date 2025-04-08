package io.confluent.quickstart;

import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Scanner;

public class TemplateProcessor {
    public static String processTemplate(String template, String gcpProjectId, String bigQueryDb) {
        String result = template;
        result = result.replace("${gcp-project-id}", gcpProjectId);
        result = result.replace("${bigquery-db}", bigQueryDb);
        return result;
    }

    public static String loadAndProcessTemplate(String templatePath, String gcpProjectId, String bigQueryDb) throws IOException, URISyntaxException {
        Path path = Paths.get(ClassLoader.getSystemResource(templatePath).toURI());
        String template = Files.readString(path);
        return processTemplate(template, gcpProjectId, bigQueryDb);
    }
} 
