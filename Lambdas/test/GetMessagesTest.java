import DoctorsNote.GetMessages;

import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;

public class GetMessagesTest {
    private GetMessages getMessages;

    @Before
    public void before() {
        getMessages = new GetMessages();
    }

    @Test
    public void testValidJSON() {
        //String actual = getMessages.handleRequest("{conversationId:\"12\",nMessages:\"20\",startIndex:\"0\",sinceWhen:\"0\"}", null);
        //Assert.assertNotNull(actual);
    }

    @Test
    public void testInvalidJSON1() {
        //String actual = getMessages.handleRequest(null, null);
        //Assert.assertNull(actual);
    }

    @Test
    public void testInvalidJSON2() {
        //String actual = getMessages.handleRequest("{\"content\"}", null);
        //Assert.assertNull(actual);
    }

    // Long term goal: Add an additional test that mocks the DBCredentialsProvider to
    // return an invalid URL to test that it does not connect.

    // Mockito is not currently a dependency so this can't be done right now without
    // adding additional overhead to the package as a whole.
}
