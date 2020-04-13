import DoctorsNote.RemoveReminder;
import DoctorsNote.ReminderRemover;
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

public class RemoveReminderTest {
    Context contextMock;
    RemoveReminder removeReminder;
    ReminderRemover reminderRemoverMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        removeReminder = spy(new RemoveReminder());
        reminderRemoverMock = Mockito.mock(ReminderRemover.class);
        doReturn(reminderRemoverMock).when(removeReminder).makeReminderRemover();
    }

    @Test
    public void testValidReturn() throws SQLException {
        ReminderRemover.RemoveReminderResponse responseMock = Mockito.mock(ReminderRemover.RemoveReminderResponse.class);
        when(reminderRemoverMock.remove(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, removeReminder.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(reminderRemoverMock.remove(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            removeReminder.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
