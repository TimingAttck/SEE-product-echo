package lu.claude.ohlhoff.echo;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import static org.assertj.core.internal.bytebuddy.matcher.ElementMatchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
class EchoEndpointTest {

	private MockMvc mockMvc;

	@Autowired
	private WebApplicationContext webAppContext;

	@BeforeEach
	public void setup() {
		mockMvc = MockMvcBuilders.webAppContextSetup(webAppContext).build();
	}

	@Test
	public void echoShouldReturnAnonIfNoNameDefined() throws Exception {

		String expected = "Hello Anon, you are awesome :)";

		this.mockMvc
				.perform(get("/echo?name="))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.msg").value(expected));
	}

	@Test
	public void echoShouldReturnExceptionIfNameParamMissing() throws Exception {

		this.mockMvc
				.perform(get("/echo"))
				.andExpect(status().is(400));

	}

	@Test
	public void echoShouldReturnTheDefinedName() throws Exception {

		String expected = "Hello Claude, you are awesome :)";

		this.mockMvc
				.perform(get("/echo?name=Claude"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.msg").value(expected));
	}

}
