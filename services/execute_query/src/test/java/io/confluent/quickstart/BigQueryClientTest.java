package io.confluent.quickstart;

import com.google.cloud.bigquery.TableResult;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;

import static org.junit.Assert.assertNotNull;

public class BigQueryClientTest {
    BigQueryClient client;

    final String QUERY =
            "SELECT * FROM " +
            "`csid-281116.gcp_genai_demo.covid_hospital_occupancy` " +
            "LIMIT 10";

    @Before
    public void setup() {
        client = new BigQueryClient(QUERY);
    }

    @Test
    public void testOne() throws IOException {
        TableResult result = client.simpleQuery(QUERY);
        assertNotNull(result);
        result.iterateAll().forEach(rows -> rows.forEach(row -> System.out.println(row.getValue())));

        String output = client.runQuery("test");
        assertNotNull(output);
        System.out.println(output);
    }
}