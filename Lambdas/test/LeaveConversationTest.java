import DoctorsNote.ConversationLeaver;
import DoctorsNote.LeaveConversation;
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

public class LeaveConversationTest {
    Context contextMock;
    LeaveConversation leaveConversation;
    ConversationLeaver conversationLeaverMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        leaveConversation = spy(new LeaveConversation());
        conversationLeaverMock = Mockito.mock(ConversationLeaver.class);
        doReturn(conversationLeaverMock).when(leaveConversation).makeConversationLeaver();
    }

    @Test
    public void testValidReturn() throws SQLException {
        ConversationLeaver.LeaveConversationResponse responseMock = Mockito.mock(ConversationLeaver.LeaveConversationResponse.class);
        when(conversationLeaverMock.leave(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, leaveConversation.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(conversationLeaverMock.leave(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            leaveConversation.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
