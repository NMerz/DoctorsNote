import DoctorsNote.RemoveEvent;
import DoctorsNote.EventRemover;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;

import java.util.HashMap;

import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

public class RemoveEventTest {
    Context contextMock;
    RemoveEvent removeEvent;
    EventRemover eventRemoverMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        removeEvent = spy(new RemoveEvent());
        eventRemoverMock = Mockito.mock(EventRemover.class);
        doReturn(eventRemoverMock).when(removeEvent).makeEventRemover();
    }

    @Test
    public void testValidReturn() {
        EventRemover.RemoveEventResponse responseMock = Mockito.mock(EventRemover.RemoveEventResponse.class);
        when(eventRemoverMock.remove(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, removeEvent.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() {
        when(eventRemoverMock.remove(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            removeEvent.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
