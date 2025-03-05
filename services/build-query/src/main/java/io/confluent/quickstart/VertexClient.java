package io.confluent.quickstart;

import com.google.cloud.vertexai.VertexAI;
import com.google.cloud.vertexai.api.GenerateContentResponse;
import com.google.cloud.vertexai.generativeai.GenerativeModel;
import com.google.cloud.vertexai.generativeai.ResponseHandler;

import java.io.IOException;

public class VertexClient {
    VertexAI vertexAI;
    final String modelName;
    final GenerativeModel model;
    public VertexClient(String projectId, String location, String modelName) {
        vertexAI = new VertexAI(projectId, location);
        this.modelName = modelName;
        model = new GenerativeModel(modelName, vertexAI);
    }

    public String callModel(String prompt) throws IOException {
        GenerateContentResponse response = model.generateContent(prompt);
        return ResponseHandler.getText(response);
    }

}
