package lu.claude.ohlhoff.echo.acceptance;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.net.MalformedURLException;
import java.net.URL;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.Platform;

public class AcceptanceTests {

    WebDriver driver;

    // Get environment variable for the server address
    private static String serverBaseURL= System.getProperty("SERVER_BASE_URL");

    // Testing constants (might need to be adapted when assumptions change)
    private final String expectedNoName = "Hello Anon, you are awesome :)";
    private final String nameToEnter = "Claude";
    private final String expectedName = "Hello "+nameToEnter+", you are awesome :)";
    private final int animationDuration = 6000;


    @BeforeEach
    public void confiugreDriver() throws MalformedURLException {


        System.out.println("==============================================================");
        System.out.println("==============================="+serverBaseURL+"===============================");

        final ChromeOptions chromeOptions = new ChromeOptions();
		chromeOptions.addArguments("--headless");
		chromeOptions.addArguments("--no-sandbox");
		chromeOptions.addArguments("--disable-dev-shm-usage");
		chromeOptions.addArguments("--window-size=1200x600");

		chromeOptions.setBinary("/usr/bin/google-chrome");
		DesiredCapabilities capability = DesiredCapabilities.chrome();
		capability.setBrowserName("chrome");
		capability.setPlatform(Platform.LINUX);

		capability.setCapability(ChromeOptions.CAPABILITY, chromeOptions);

		driver = new RemoteWebDriver(new URL("http://selenium__standalone-chrome:4444/wd/hub"), capability);
    }


    @Test
    public void validateWhenProvidedName() throws InterruptedException {
        driver.get(serverBaseURL);

        // Enter name "Claude" and click the submit button
        driver.findElement(By.id("name")).sendKeys("Claude");
        driver.findElement(By.id("submit_button")).click();

        // We are expecting the text
		String expected = expectedName;

        // Wait for the animation to finish
        Thread.sleep(animationDuration);
        
        // Retrieve the text responded by the server
        String actual = driver.findElement(By.id("output")).getText();
        
        // Validate the result
        assertEquals(expected, actual);
    }

    @Test
    public void validateWhenProvidedNoName() throws InterruptedException {
        driver.get(serverBaseURL);

        // Enter name "Claude" and click the submit button
        driver.findElement(By.id("name")).sendKeys("");
        driver.findElement(By.id("submit_button")).click();

        // We are expecting the text
		String expected = expectedNoName;

        // Wait for the animation to finish
        Thread.sleep(animationDuration);
        
        // Retrieve the text responded by the server
        String actual = driver.findElement(By.id("output")).getText();
        
        // Validate the result
        assertEquals(expected, actual);
    }

    @AfterEach
    public void tearDown() {
        driver.quit();
    }

}