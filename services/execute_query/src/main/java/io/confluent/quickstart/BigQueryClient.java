package io.confluent.quickstart;

import com.google.cloud.bigquery.*;

public class BigQueryClient {
    final BigQuery bigqueryClient;
    public BigQueryClient() {
        bigqueryClient = BigQueryOptions.getDefaultInstance().getService();
    }

    public String formatResults(TableResult results) {
        String formattedResults = results.getTotalRows() + " results. " + results.toString();
//        results.iterateAll().forEach(
//                rows -> rows.forEach(
//                        row -> System.out.println(row.getValue())));
        return formattedResults;
    }

    public String sanitizeQuery(String query) {
        String cleanQuery = query.replace("```sql", "").replace("```", "");
        return cleanQuery.trim();
    }

    public String runQuery(String query) {
        String cleanQuery = sanitizeQuery(query);
        System.out.println(cleanQuery);
        try {
            return formatResults(simpleQuery(cleanQuery));
        } catch (BigQueryException | InterruptedException e) {
            System.out.println("Query did not run \n" + e.toString());
            return "The query failed to run.";
        }
    }

    public TableResult simpleQuery(String query) throws InterruptedException {
        String cleanQuery = sanitizeQuery(query);
        // Create the query job.
        QueryJobConfiguration queryConfig = QueryJobConfiguration.newBuilder(cleanQuery).build();
        // Execute the query.
        TableResult result = bigqueryClient.query(queryConfig);
        // Print the results.
        result.iterateAll().forEach(rows -> rows.forEach(row -> System.out.println(row.getValue())));
        return result;
    }

}
