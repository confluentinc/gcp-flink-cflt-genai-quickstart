package io.confluent.quickstart;

import org.junit.Before;
import org.junit.Test;

import java.io.IOException;

import static org.junit.Assert.assertNotNull;

public class VertexClientTest {
    VertexClient client;

    @Before
    public void setup() {
        String projectId = "csid-281116";
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


}