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
    void testLoadAndProcessTemplate() throws IOException, URISyntaxException {
        String templatePath = "build_query_prompt.txt";
        String projectId = "testProjectId";
        String database = "testDatabase";

        String processed = TemplateProcessor.loadAndProcessTemplate(templatePath, projectId, database);

        // Verify the template was loaded and processed
        assertNotNull(processed);
        assertTrue(processed.contains(projectId), "Processed template should contain project ID");
        assertTrue(processed.contains(database), "Processed template should contain database name");
        assertFalse(processed.contains("${gcp-project-id}"), "Template should not contain unprocessed placeholders");
        assertFalse(processed.contains("${bigquery-db}"), "Template should not contain unprocessed placeholders");
    }
}
