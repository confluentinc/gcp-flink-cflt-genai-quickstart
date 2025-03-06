package io.confluent.quickstart;

import com.google.cloud.bigquery.TableResult;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;

import static org.junit.Assert.assertNotNull;

public class BigQueryClientTest {
    BigQueryClient client;

    final String QUERY =
            "SELECT\n" +
                    "    Appointments.AppointmentDate,\n" +
                    "    Appointments.Reason\n" +
                    "  FROM\n" +
                    "    `csid-281116.doctors_practice.Appointments` AS Appointments\n" +
                    "  JOIN\n" +
                    "    `csid-281116.doctors_practice.Patients` AS Patients ON Appointments.PatientID = Patients.PatientID\n" +
                    "  WHERE Patients.FirstName = 'Joseph'\n" +
                    "ORDER BY\n" +
                    "  Appointments.AppointmentDate DESC\n" +
                    "LIMIT 3\n";

    @Before
    public void setup() {
        client = new BigQueryClient(QUERY);
    }

    @Test
    public void testSimple() throws IOException {
        TableResult result = client.simpleQuery(QUERY);
        assertNotNull(result);
        result.iterateAll().forEach(rows -> rows.forEach(row -> System.out.println(row.getValue())));
    }
    @Test
    public void testFull() throws IOException {
        String output = client.runQuery("");
        assertNotNull(output);
        System.out.println(output);
    }

}
