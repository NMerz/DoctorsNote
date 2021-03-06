import DoctorsNote.AddReminder;
import DoctorsNote.ReminderAdder;
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

public class AddReminderTest {
    Context contextMock;
    AddReminder addReminder;
    ReminderAdder reminderAdderMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        addReminder = spy(new AddReminder());
        reminderAdderMock = Mockito.mock(ReminderAdder.class);
        doReturn(reminderAdderMock).when(addReminder).makeReminderAdder();
    }

    @Test
    public void testValidReturn() throws SQLException {
        ReminderAdder.AddReminderResponse responseMock = Mockito.mock(ReminderAdder.AddReminderResponse.class);
        when(reminderAdderMock.add(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, addReminder.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(reminderAdderMock.add(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            addReminder.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
