package io.confluent.pie.quickstart.gcp.audio.socket;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/")
public class WebSocketController {

    @GetMapping("{path:[^\\.]*}")
    public String forward() {
        return "forward:/index.html";
    }
}
