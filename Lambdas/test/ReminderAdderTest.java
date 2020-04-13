import DoctorsNote.ReminderAdder;
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

public class ReminderAdderTest {
    Connection connectionMock = mock(Connection.class);

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("content", "test reminder");
        jsonBody.put("remindee", "0000000001");
        jsonBody.put("timeCreated", 1L);
        jsonBody.put("alertTime", 2L);
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "sub-id123"); //Note: not an accurate length for sample id
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testEmptyInputs() {
        ReminderAdder reminderAdder = new ReminderAdder(connectionMock);
        Assert.assertEquals(null, reminderAdder.add(new HashMap<>(), mock(Context.class)));
    }

    @Test()
    public void testMissingInput() {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("content");
        ReminderAdder reminderAdder = new ReminderAdder(connectionMock);
        Assert.assertEquals(null, reminderAdder.add(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testBadInput() {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).put("content", 1);
        ReminderAdder reminderAdder = new ReminderAdder(connectionMock);
        Assert.assertEquals(null, reminderAdder.add(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testConnectionError() {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("content");
        ReminderAdder reminderAdder = new ReminderAdder(connectionMock);
        try {
            PreparedStatement statementMock = Mockito.mock(PreparedStatement.class);
            Mockito.when(statementMock.executeUpdate()).thenThrow(new RuntimeException());
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(statementMock);
        } catch (SQLException e) {
            Assert.fail();
        }
        Assert.assertEquals(null, reminderAdder.add(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testCompleteInput() {
        HashMap incompleteMap = getSampleMap();
        try {
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(Mockito.mock(PreparedStatement.class));
        } catch (SQLException e) {
            Assert.fail();
        }
        ReminderAdder reminderAdder = new ReminderAdder(connectionMock);
        Assert.assertNotNull(reminderAdder.add(incompleteMap, mock(Context.class)));
    }
}
