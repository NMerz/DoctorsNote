import DoctorsNote.ReminderGetter;
import com.amazonaws.services.lambda.runtime.CognitoIdentity;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;
import org.mockito.Mockito;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;


public class ReminderGetterTest {
    Connection connectionMock;
    Context contextMock;
    CognitoIdentity identityMock;

    @Before
    public void beforeTests() {
        connectionMock = mock(Connection.class);
        contextMock = mock(Context.class);
        identityMock = mock(CognitoIdentity.class);
        when(contextMock.getIdentity()).thenReturn(identityMock);
        when(identityMock.getIdentityId()).thenReturn("mock string");
        when(identityMock.getIdentityPoolId()).thenReturn("mock string");
    }

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("since", 1L);
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "0000000001"); //Note: not an accurate length for sample id
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testEmptyInputs() throws SQLException {
        ReminderGetter reminderGetter = new ReminderGetter(connectionMock);
        Assert.assertEquals(null, reminderGetter.get(new HashMap<>(), contextMock));
    }

    @Test()
    public void testMissingInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("context");
        ReminderGetter reminderGetter = new ReminderGetter(connectionMock);
        Assert.assertEquals(null, reminderGetter.get(incompleteMap, contextMock));
    }

    @Test()
    public void testBadInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).put("since", "1");
        ReminderGetter reminderGetter = new ReminderGetter(connectionMock);
        Assert.assertEquals(null, reminderGetter.get(incompleteMap, contextMock));
    }

    @Test()
    public void testConnectionError() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ReminderGetter reminderGetter = new ReminderGetter(connectionMock);
        try {
            PreparedStatement statementMock = mock(PreparedStatement.class);
            when(statementMock.executeUpdate()).thenThrow(new RuntimeException());
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(statementMock);
        } catch (SQLException e) {
            Assert.fail();
        }
        Assert.assertEquals(null, reminderGetter.get(incompleteMap, contextMock));
    }

    @Test()
    public void testCompleteInput() throws SQLException {
        HashMap completeMap = getSampleMap();
        try {
            // Mocking necessary connection elements
            PreparedStatement psMock = mock(PreparedStatement.class);
            ResultSet rsMock = mock(ResultSet.class);
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(psMock);
            when(psMock.executeQuery()).thenReturn(rsMock);
            when(rsMock.next()).thenReturn(false);
        } catch (SQLException e) {
            Assert.fail();
        }
        ReminderGetter reminderGetter = new ReminderGetter(connectionMock);
        Assert.assertNotNull(reminderGetter.get(completeMap, contextMock));
    }
}
