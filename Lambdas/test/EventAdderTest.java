import DoctorsNote.EventAdder;
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

public class EventAdderTest {
    Connection connectionMock = mock(Connection.class);

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("content", "Sample content");
        jsonBody.put("timeScheduled", 20L);
        jsonBody.put("withID", "sample-id");
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "sub-id123"); //Note: not an accurate length for sample id
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testEmptyInputs() throws SQLException {
        EventAdder eventAdder = new EventAdder(connectionMock);
        Assert.assertEquals(null, eventAdder.add(new HashMap<>(), mock(Context.class)));
    }

    @Test()
    public void testMissingInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("content");
        EventAdder eventAdder = new EventAdder(connectionMock);
        Assert.assertEquals(null, eventAdder.add(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testBadInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).put("content", 1);
        EventAdder eventAdder = new EventAdder(connectionMock);
        Assert.assertEquals(null, eventAdder.add(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testConnectionError() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("content");
        EventAdder eventAdder = new EventAdder(connectionMock);
        try {
            PreparedStatement statementMock = Mockito.mock(PreparedStatement.class);
            Mockito.when(statementMock.executeUpdate()).thenThrow(new RuntimeException());
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(statementMock);
        } catch (SQLException e) {
            Assert.fail();
        }
        Assert.assertEquals(null, eventAdder.add(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testConnectionRobustness() throws SQLException {
        HashMap incompleteMap = getSampleMap();

        // Mocking necessary connection elements
        PreparedStatement statementMock = Mockito.mock(PreparedStatement.class);
        when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(statementMock);
        when(statementMock.executeUpdate()).thenThrow(new SQLException());

        EventAdder eventAdder = new EventAdder(connectionMock);
        Assert.assertNull(eventAdder.add(incompleteMap, mock(Context.class)));

        // Asserts that close() has been called at least once
        Mockito.verify(connectionMock).close();
    }

    @Test()
    public void testCompleteInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        try {
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(Mockito.mock(PreparedStatement.class));
        } catch (SQLException e) {
            Assert.fail();
        }
        EventAdder eventAdder = new EventAdder(connectionMock);
        Assert.assertNotNull(eventAdder.add(incompleteMap, mock(Context.class)));
    }
}
