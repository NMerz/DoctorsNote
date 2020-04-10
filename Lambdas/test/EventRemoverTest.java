import DoctorsNote.EventRemover;
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

public class EventRemoverTest {
    Connection connectionMock = mock(Connection.class);

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("appointmentID", "102");
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "sub-id123");   // Note: not an accurate length for sample id
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testEmptyInputs() throws SQLException {
        EventRemover eventRemover = new EventRemover(connectionMock);
        Assert.assertEquals(null, eventRemover.remove(new HashMap<>(), mock(Context.class)));
    }

    @Test()
    public void testMissingInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("eventID");
        EventRemover eventRemover = new EventRemover(connectionMock);
        Assert.assertEquals(null, eventRemover.remove(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testBadInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).put("eventID", null);
        EventRemover eventRemover = new EventRemover(connectionMock);
        Assert.assertEquals(null, eventRemover.remove(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testConnectionError() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("eventID");
        EventRemover eventRemover = new EventRemover(connectionMock);
        try {
            PreparedStatement statementMock = Mockito.mock(PreparedStatement.class);
            Mockito.when(statementMock.executeUpdate()).thenThrow(new RuntimeException());
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(statementMock);
        } catch (SQLException e) {
            Assert.fail();
        }
        Assert.assertEquals(null, eventRemover.remove(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testCompleteInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        try {
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(Mockito.mock(PreparedStatement.class));
        } catch (SQLException e) {
            Assert.fail();
        }
        EventRemover eventRemover = new EventRemover(connectionMock);
        Assert.assertNotNull(eventRemover.remove(incompleteMap, mock(Context.class)));
    }
}
