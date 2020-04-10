import DoctorsNote.GetReminders;
import DoctorsNote.ReminderGetter;
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

public class GetRemindersTest {
    Context contextMock;
    GetReminders getReminders;
    ReminderGetter reminderGetterMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        getReminders = spy(new GetReminders());
        reminderGetterMock = Mockito.mock(ReminderGetter.class);
        doReturn(reminderGetterMock).when(getReminders).makeReminderGetter();
    }

    @Test
    public void testValidReturn() throws SQLException {
        ReminderGetter.GetReminderResponse responseMock = Mockito.mock(ReminderGetter.GetReminderResponse.class);
        when(reminderGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, getReminders.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(reminderGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            getReminders.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
