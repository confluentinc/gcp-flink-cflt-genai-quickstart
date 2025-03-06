package io.confluent.quickstart;

import com.google.cloud.bigquery.*;

import java.io.IOException;

public class BigQueryClient {
    final String query;
    final BigQuery bigqueryClient;
    public BigQueryClient(String query) {
        this.query = query;
        bigqueryClient = BigQueryOptions.getDefaultInstance().getService();
    }



    public String runQuery(String param1) throws IOException {
        String finalQuery = query;
        // prepare query (merge with params)
        // execute query
        TableResult result = simpleQuery(finalQuery);
        // process results
        // result.iterateAll().forEach(rows -> rows.forEach(row -> System.out.println(row.getValue())));
        return "something";
    }

    public TableResult simpleQuery(String query) {
        try {
            // Create the query job.
            QueryJobConfiguration queryConfig = QueryJobConfiguration.newBuilder(query).build();

            // Execute the query.
            TableResult result = bigqueryClient.query(queryConfig);

            // Print the results.
            result.iterateAll().forEach(rows -> rows.forEach(row -> System.out.println(row.getValue())));

            return result;
        } catch (BigQueryException | InterruptedException e) {
            System.out.println("Query did not run \n" + e.toString());
            return null;
        }
    }

}
