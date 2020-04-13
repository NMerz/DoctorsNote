import DoctorsNote.AddEvent;
import DoctorsNote.EventAdder;
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

public class AddEventTest {
    Context contextMock;
    AddEvent addEvent;
    EventAdder eventAdderMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        addEvent = spy(new AddEvent());
        eventAdderMock = Mockito.mock(EventAdder.class);
        doReturn(eventAdderMock).when(addEvent).makeEventAdder();
    }

    @Test
    public void testValidReturn() throws SQLException {
        EventAdder.AddEventResponse responseMock = Mockito.mock(EventAdder.AddEventResponse.class);
        when(eventAdderMock.add(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, addEvent.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(eventAdderMock.add(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            addEvent.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
