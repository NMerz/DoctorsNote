import DoctorsNote.RemoveMessage;
import DoctorsNote.MessageRemover;
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

public class RemoveMessageTest {
    Context contextMock;
    RemoveMessage removeMessage;
    MessageRemover messageRemoverMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        removeMessage = spy(new RemoveMessage());
        messageRemoverMock = Mockito.mock(MessageRemover.class);
        doReturn(messageRemoverMock).when(removeMessage).makeMessageRemover();
    }

    @Test
    public void testValidReturn() throws SQLException {
        MessageRemover.RemoveMessageResponse responseMock = Mockito.mock(MessageRemover.RemoveMessageResponse.class);
        when(messageRemoverMock.remove(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, removeMessage.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(messageRemoverMock.remove(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            removeMessage.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
