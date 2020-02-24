import DoctorsNote.AddMessage;

import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;

public class AddMessageTest {
    private AddMessage addMessage;

    @Before
    public void before() {
        addMessage = new AddMessage();
    }

    @Test
    public void testValidJSON() {
        String actual = addMessage.handleRequest("{conversationId:\"12\",content:\"Hello world\",senderId:\"0000000000\"}", null);
        Assert.assertEquals(actual, "{}");
    }

    @Test
    public void testInvalidJSON1() {
        String actual = addMessage.handleRequest(null, null);
        Assert.assertNull(actual);
    }

    @Test
    public void testInvalidJSON2() {
        String actual = addMessage.handleRequest("{\"conversationId\"}", null);
        Assert.assertNull(actual);
    }

    // Long term goal: Add an additional test that mocks the DBCredentialsProvider to
    // return an invalid URL to test that it does not connect.

    // Mockito is not currently a dependency so this can't be done right now without
    // adding additional overhead to the package as a whole.
}
