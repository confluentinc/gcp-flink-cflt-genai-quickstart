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
        String textPrompt = "Summarize the following paragraphs in 2 sentences. \n\n" +
                "The dream of human flight must " +
                "have begun with observation of birds soaring through the sky. For millennia, however, progress was " +
                "retarded by attempts to design aircraft that emulated the beating of a bird’s wings. The " +
                "generations of experimenters and dreamers who focused their attention on ornithopters—machines " +
                "in which flapping wings generated both lift and propulsion—contributed nothing substantial to the " +
                "final solution of the problems blocking the route to mechanical flight.\n" +
                "\n" +
                "Thus, the story of the invention of the airplane begins in the 16th, 17th, and 18th centuries, " +
                "with the first serious research into aerodynamics—the study of the forces operating on a solid " +
                "body (for instance, a wing when it is immersed in a stream of air). Leonardo da Vinci and Galileo " +
                "Galilei in Italy, Christiaan Huygens in the Netherlands, and Isaac Newton in England all " +
                "contributed to an understanding of the relationship between resistance (drag) and such factors as " +
                "the surface area of an object exposed to the stream and the density of a fluid. Swiss " +
                "mathematicians Daniel Bernoulli and Leonhard Euler and British engineer John Smeaton explained " +
                "the relationship between pressure and velocity and provided information that enabled a later " +
                "generation of engineers to calculate aerodynamic forces.";


        String output = client.callModel(textPrompt);
        System.out.println(output);

        assertNotNull(output);
    }


}