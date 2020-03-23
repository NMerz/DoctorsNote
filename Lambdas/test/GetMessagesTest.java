import DoctorsNote.GetMessages;
import DoctorsNote.MessageGetter;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;

import java.util.HashMap;

import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

public class GetMessagesTest {
    Context contextMock;
    GetMessages getMessages;
    MessageGetter messageGetterMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        getMessages = spy(new GetMessages());
        messageGetterMock = Mockito.mock(MessageGetter.class);
        doReturn(messageGetterMock).when(getMessages).makeMessageGetter();
    }

    @Test
    public void testValidReturn() {
        MessageGetter.GetMessagesResponse responseMock = Mockito.mock(MessageGetter.GetMessagesResponse.class);
        when(messageGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, getMessages.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() {
        when(messageGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            getMessages.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
