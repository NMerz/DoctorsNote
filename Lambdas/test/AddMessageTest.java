import DoctorsNote.AddMessage;

import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;

import java.util.HashMap;

public class AddMessageTest {
    private AddMessage addMessage;

    @Before
    public void before() {
        addMessage = new AddMessage();
    }

    @Test
    public void testValidJSON() {
        HashMap<String, Object> map = new HashMap<>();
        HashMap<String, Object> internalMap = new HashMap<>();
        internalMap.put("conversationId", "12");
        internalMap.put("content", "Sent from Unit Tests");
        internalMap.put("senderId", "0");
        map.put("body", internalMap);
        AddMessage.AddMessageResponse actual = (AddMessage.AddMessageResponse)addMessage.handleRequest(map, null);
        Assert.assertNotNull(actual);
    }

    @Test
    public void testInvalidJSON1() {
        AddMessage.AddMessageResponse actual = (AddMessage.AddMessageResponse)addMessage.handleRequest(null, null);
        Assert.assertNull(actual);
    }

    @Test
    public void testInvalidJSON2() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("body", null);
        AddMessage.AddMessageResponse actual = (AddMessage.AddMessageResponse)addMessage.handleRequest(map, null);
        Assert.assertNull(actual);
    }

    // Long term goal: Add an additional test that mocks the DBCredentialsProvider to
    // return an invalid URL to test that it does not connect.

    // Mockito is not currently a dependency so this can't be done right now without
    // adding additional overhead to the package as a whole.
}
