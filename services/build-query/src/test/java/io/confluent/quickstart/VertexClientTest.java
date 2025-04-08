package io.confluent.quickstart;

import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.net.URISyntaxException;

import static org.junit.Assert.assertNotNull;

public class VertexClientTest {
    VertexClient client;
    String projectId;

    @Before
    public void setup() {
        projectId = "csid-281116";
        String location = "europe-west1";
        String modelName = "gemini-2.0-flash-001";

        client = new VertexClient(projectId, location, modelName);
    }

    @Test
    public void testOne() throws IOException {
        String textPrompt = "TODO";

        String output = client.callModel(textPrompt);
        System.out.println(output);

        assertNotNull(output);
    }

    @Test
    public void testResourcePrompt() throws IOException, URISyntaxException {
        String textPrompt = TemplateProcessor.loadAndProcessTemplate("build_query_prompt.txt", projectId, "your-bigquery-db");
        String query = "what was the medication taken by Joseph Burns on their last 2 visits";
        String output = client.callModel(textPrompt + query);
        System.out.println(output);

        textPrompt = TemplateProcessor.loadAndProcessTemplate("build_query_prompt.txt", projectId, "your-bigquery-db");
        query = "Give me the latest 3 appointments for patient Joseph Burns and the reason for the visit";
        output = client.callModel(textPrompt + query);
        System.out.println(output);

        assertNotNull(output);
    }
}