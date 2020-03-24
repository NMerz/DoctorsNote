import DoctorsNote.ReminderPurger;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Test;
import org.mockito.Mockito;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

public class ReminderPurgerTest {
    Connection connectionMock = mock(Connection.class);

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testConnectionError() {
        HashMap incompleteMap = getSampleMap();
        ReminderPurger reminderPurger = new ReminderPurger(connectionMock);
        try {
            PreparedStatement statementMock = Mockito.mock(PreparedStatement.class);
            Mockito.when(statementMock.executeUpdate()).thenThrow(new RuntimeException());
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(statementMock);
        } catch (SQLException e) {
            Assert.fail();
        }
        Assert.assertEquals(null, reminderPurger.purge(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testCompleteInput() {
        HashMap incompleteMap = getSampleMap();
        try {
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(Mockito.mock(PreparedStatement.class));
        } catch (SQLException e) {
            Assert.fail();
        }
        ReminderPurger reminderPurger = new ReminderPurger(connectionMock);
        Assert.assertNotNull(reminderPurger.purge(incompleteMap, mock(Context.class)));
    }
}
