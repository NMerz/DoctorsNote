import DoctorsNote.AddMessage;
import DoctorsNote.ConversationList;

import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;

import java.util.HashMap;

public class ConversationListTest {
    private ConversationList conversationList = new ConversationList();

    @Before
    public void before() {
        conversationList = new ConversationList();
    }

    @Test
    public void testValidJSON() {
        HashMap<String, Object> map = new HashMap<>();
        HashMap<String, Object> internalMap = new HashMap<>();
        internalMap.put("dn-user-id", "12");
        map.put("body", internalMap);
        ConversationList.ConversationListResponse actual = conversationList.handleRequest(map, null);
        Assert.assertNotNull(map);
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
