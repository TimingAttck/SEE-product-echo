package lu.claude.ohlhoff.echo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages="lu.claude.ohlhoff.echo")
public class EchoApplication extends SpringBootServletInitializer {

	public static void main(String[] args) {
		SpringApplication.run(EchoApplication.class, args);
	}

}
