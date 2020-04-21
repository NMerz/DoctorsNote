import DoctorsNote.PurgeMessages;
import DoctorsNote.MessagePurger;
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

public class PurgeMessagesTest {
    Context contextMock;
    PurgeMessages purgeMessages;
    MessagePurger messagePurgerMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        purgeMessages = spy(new PurgeMessages());
        messagePurgerMock = Mockito.mock(MessagePurger.class);
        doReturn(messagePurgerMock).when(purgeMessages).makeMessagePurger();
    }

    @Test
    public void testValidReturn() throws SQLException {
        MessagePurger.PurgeMessageResponse responseMock = Mockito.mock(MessagePurger.PurgeMessageResponse.class);
        when(messagePurgerMock.purge(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, purgeMessages.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(messagePurgerMock.purge(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            purgeMessages.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
