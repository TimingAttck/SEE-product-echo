package lu.claude.ohlhoff.echo.unit;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import lu.claude.ohlhoff.echo.controllers.EchoController;

@SpringBootTest
public class UnitTests {

    @Autowired
    private EchoController echoContoller;
    
	@Test
	public void echoShouldReturnAnonIfNoNameDefined() throws Exception {

        String name = "";
		String expected = "Hello Anon, you are awesome :)";
        String actual = echoContoller.echo(name).msg.toString();
        assertEquals(expected, actual);

	}

	@Test
	public void echoShouldReturnTheDefinedName() throws Exception {

        String name = "Claude";
		String expected = "Hello Claude, you are awesome :)";
        String actual = echoContoller.echo(name).msg.toString();
        assertEquals(expected, actual);

	}
    
}
