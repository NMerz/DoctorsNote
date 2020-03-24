import DoctorsNote.CreateConversation;

import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;

public class CreateConversationTest {
    private CreateConversation createConversation;

    @Before
    public void before() {
        createConversation = new CreateConversation();
    }

    @Test
    public void testInvalidJSON1() {
        String actual = createConversation.handleRequest(null, null);
        Assert.assertNull(actual);
    }

    @Test
    public void testInvalidJSON2() {
        String actual = createConversation.handleRequest("{\"conversationName\"}", null);
        Assert.assertNull(actual);
    }

    // Long term goal: Add an additional test that mocks the DBCredentialsProvider to
    // return an invalid URL to test that it does not connect.

    // Mockito is not currently a dependency so this can't be done right now without
    // adding additional overhead to the package as a whole.
}
