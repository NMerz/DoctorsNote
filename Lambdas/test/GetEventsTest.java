import DoctorsNote.GetEvents;
import DoctorsNote.EventGetter;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;

import java.util.HashMap;

import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

public class GetEventsTest {
    Context contextMock;
    GetEvents getEvents;
    EventGetter eventGetterMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        getEvents = spy(new GetEvents());
        eventGetterMock = Mockito.mock(EventGetter.class);
        doReturn(eventGetterMock).when(getEvents).makeEventGetter();
    }

    @Test
    public void testValidReturn() {
        EventGetter.GetEventsResponse responseMock = Mockito.mock(EventGetter.GetEventsResponse.class);
        when(eventGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, getEvents.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() {
        when(eventGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            getEvents.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
