package lu.claude.ohlhoff.echo.controllers;

import lu.claude.ohlhoff.echo.entities.EchoResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class EchoController {

    @GetMapping("/echo")
    public EchoResponse echo(@RequestParam(value="name", required=true) String name) {

        if (name.isBlank())
            name = "Anon";

        return new EchoResponse("Hello "+name+", you are awesome :)");
    }

}
