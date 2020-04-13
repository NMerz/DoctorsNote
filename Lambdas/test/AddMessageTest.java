import DoctorsNote.AddMessage;
import DoctorsNote.MessageAdder;
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

public class AddMessageTest {
    Context contextMock;
    AddMessage addMessage;
    MessageAdder messageAdderMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        addMessage = spy(new AddMessage());
        messageAdderMock = Mockito.mock(MessageAdder.class);
        doReturn(messageAdderMock).when(addMessage).makeMessageAdder();
    }

    @Test
    public void testValidReturn() throws SQLException {
        MessageAdder.AddMessageResponse responseMock = Mockito.mock(MessageAdder.AddMessageResponse.class);
        when(messageAdderMock.add(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, addMessage.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(messageAdderMock.add(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            addMessage.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
