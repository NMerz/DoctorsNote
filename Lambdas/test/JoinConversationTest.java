import DoctorsNote.ConversationJoiner;
import DoctorsNote.JoinConversation;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;

import java.sql.SQLException;
import java.util.HashMap;

import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

public class JoinConversationTest {
    Context contextMock;
    JoinConversation joinConversation;
    ConversationJoiner conversationJoinerMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        joinConversation = spy(new JoinConversation());
        conversationJoinerMock = Mockito.mock(ConversationJoiner.class);
        doReturn(conversationJoinerMock).when(joinConversation).makeConversationJoiner();
    }

    @Test
    public void testValidReturn() throws SQLException {
        ConversationJoiner.JoinConversationResponse responseMock = Mockito.mock(ConversationJoiner.JoinConversationResponse.class);
        when(conversationJoinerMock.join(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, joinConversation.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(conversationJoinerMock.join(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            joinConversation.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
