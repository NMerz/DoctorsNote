import DoctorsNote.ConversationList;
import DoctorsNote.ListConversations;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;

import java.util.HashMap;

import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

public class ConversationListTest {
    Context contextMock;
    ConversationList conversationList;
    ListConversations listConversationsMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        conversationList = spy(new ConversationList());
        listConversationsMock = Mockito.mock(ListConversations.class);
        doReturn(listConversationsMock).when(conversationList).makeListConversations();
    }

    @Test
    public void testValidReturn() {
        ListConversations.ConversationListResponse responseMock = Mockito.mock(ListConversations.ConversationListResponse.class);
        when(listConversationsMock.list(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, conversationList.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() {
        when(listConversationsMock.list(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            conversationList.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
