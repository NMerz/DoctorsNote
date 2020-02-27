import DoctorsNote.ConversationList;

import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;

public class ConversationListTest {
    private ConversationList conversationList = new ConversationList();

    @Before
    public void before() {
        ConversationList cl = new ConversationList();
    }

    @Test
    public void testValidJSON() {
        //String actual = conversationList.handleRequest("{\"userId\":\"12345678910\"}", null);
        //Assert.assertTrue(actual.matches("\\{\"conversationList\":\\[.*\\]\\}"));
    }

    @Test
    public void testInvalidJSON1() {
        //String actual = conversationList.handleRequest(null, null);
        //Assert.assertNull(actual);
    }

    @Test
    public void testInvalidJSON2() {
        //String actual = conversationList.handleRequest("{\"userId\"}", null);
        //Assert.assertNull(actual);
    }

    // Long term goal: Add an additional test that mocks the DBCredentialsProvider to
    // return an invalid URL to test that it does not connect.

    // Mockito is not currently a dependency so this can't be done right now without
    // adding additional overhead to the package as a whole.
}
