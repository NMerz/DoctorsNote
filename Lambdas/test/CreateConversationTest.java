import DoctorsNote.AddMessage;
import DoctorsNote.CreateConversation;

import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;

import java.util.HashMap;

public class CreateConversationTest {
    private CreateConversation createConversation;

    @Before
    public void before() {
        createConversation = new CreateConversation();
    }

    @Test
    public void testValidJSON() {
        HashMap<String, Object> map = new HashMap<>();
        HashMap<String, Object> internalMap = new HashMap<>();
        internalMap.put("conversationName", "Test Conversation");
        map.put("body", internalMap);
        CreateConversation.CreateConversationResponse actual = createConversation.handleRequest(map, null);
        Assert.assertNotNull(map);
    }

    @Test
    public void testInvalidJSON1() {
        CreateConversation.CreateConversationResponse actual = createConversation.handleRequest(null, null);
        Assert.assertNull(actual);
    }

    @Test
    public void testInvalidJSON2() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("body", null);
        CreateConversation.CreateConversationResponse actual = createConversation.handleRequest(map, null);
        Assert.assertNull(actual);
    }

    // Long term goal: Add an additional test that mocks the DBCredentialsProvider to
    // return an invalid URL to test that it does not connect.

    // Mockito is not currently a dependency so this can't be done right now without
    // adding additional overhead to the package as a whole.
}
