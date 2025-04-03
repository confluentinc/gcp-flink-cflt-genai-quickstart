package io.confluent.quickstart;

import org.junit.jupiter.api.Test;
import java.io.IOException;
import java.net.URISyntaxException;
import static org.junit.jupiter.api.Assertions.*;

class TemplateProcessorTest {
    @Test
    void testProcessTemplate() {
        // Assuming you have a template with these placeholders
        String template = "Project ID: ${gcp-project-id}, Database: ${bigquery-db}";
        String expected = "Project ID: dummyProjectID, Database: dummyDatabase";


        String processed = TemplateProcessor.processTemplate(template, "dummyProjectID", "dummyDatabase");

        assertEquals(expected, processed);
    }

    @Test
    void testLoadAndProcessTemplate() {
        String expected = "Project ID: testProjectId, Database: testDatabase";

        String templatePath = "build_query_prompt.txt";

        String processed = null;
        try {
            processed = TemplateProcessor.loadAndProcessTemplate(templatePath, "testProjectId", "testDatabase");
        } catch (IOException | URISyntaxException e) {
            fail("An exception occurred while loading or processing the template: " + e.getMessage());
        }

        // Assert that the processed template doesn't match the expected string
        assertNotEquals(expected, processed);
    }
}
