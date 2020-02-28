import DoctorsNote.CreateConversation;
import DoctorsNote.GetMessages;

import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;

import java.util.HashMap;

public class GetMessagesTest {
    private GetMessages getMessages;

    @Before
    public void before() {
        getMessages = new GetMessages();
    }

    @Test
    public void testValidJSON() {
        HashMap<String, Object> map = new HashMap<>();
        HashMap<String, Object> internalMap = new HashMap<>();
        internalMap.put("conversationId", "Test Conversation");
        internalMap.put("nMessages", "50");
        internalMap.put("startIndex", "0");
        internalMap.put("sinceWhen", "0");
        map.put("body", internalMap);
        GetMessages.GetMessagesResponse actual = getMessages.handleRequest(map, null);
        Assert.assertNotNull(map);
    }

    @Test
    public void testInvalidJSON1() {
        GetMessages.GetMessagesResponse actual = getMessages.handleRequest(null, null);
        Assert.assertNull(actual);
    }

    @Test
    public void testInvalidJSON2() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("body", null);
        GetMessages.GetMessagesResponse actual = getMessages.handleRequest(map, null);
        Assert.assertNull(actual);
    }

    // Long term goal: Add an additional test that mocks the DBCredentialsProvider to
    // return an invalid URL to test that it does not connect.

    // Mockito is not currently a dependency so this can't be done right now without
    // adding additional overhead to the package as a whole.
}
