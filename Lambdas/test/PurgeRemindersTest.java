import DoctorsNote.PurgeReminders;
import DoctorsNote.ReminderPurger;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;

import java.util.HashMap;

import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

public class PurgeRemindersTest {
    Context contextMock;
    PurgeReminders purgeReminders;
    ReminderPurger reminderPurgerMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        purgeReminders = spy(new PurgeReminders());
        reminderPurgerMock = Mockito.mock(ReminderPurger.class);
        doReturn(reminderPurgerMock).when(purgeReminders).makeReminderPurger();
    }

    @Test
    public void testValidReturn() {
        ReminderPurger.PurgeReminderResponse responseMock = Mockito.mock(ReminderPurger.PurgeReminderResponse.class);
        when(reminderPurgerMock.purge(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, purgeReminders.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() {
        when(reminderPurgerMock.purge(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            purgeReminders.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
