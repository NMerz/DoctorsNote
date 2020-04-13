import DoctorsNote.ListConversations;
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
import java.sql.Timestamp;
import java.util.HashMap;

public class ListConversationsTest {
    Connection connectionMock;
    Context contextMock;
    CognitoIdentity identityMock;

    @Before
    public void beforeTests() {
        connectionMock = Mockito.mock(Connection.class);
        contextMock = Mockito.mock(Context.class);
        identityMock = Mockito.mock(CognitoIdentity.class);
        Mockito.when(contextMock.getIdentity()).thenReturn(identityMock);
        Mockito.when(identityMock.getIdentityId()).thenReturn("mock string");
        Mockito.when(identityMock.getIdentityPoolId()).thenReturn("mock string");
    }

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "sub-id123"); //Note: not an accurate length for sample id
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testEmptyInputs() throws SQLException {
        ListConversations listConversations = new ListConversations(connectionMock);
        Assert.assertEquals(null, listConversations.list(new HashMap<>(), contextMock));
    }

    @Test()
    public void testMissingInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("context");
        ListConversations listConversations = new ListConversations(connectionMock);
        Assert.assertEquals(null, listConversations.list(incompleteMap, contextMock));
    }

    @Test()
    public void testBadInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("context")).put("sub", 1);
        ListConversations listConversations = new ListConversations(connectionMock);
        Assert.assertEquals(null, listConversations.list(incompleteMap, contextMock));
    }

    @Test()
    public void testConnectionError() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ListConversations listConversations = new ListConversations(connectionMock);
        try {
            PreparedStatement statementMock = Mockito.mock(PreparedStatement.class);
            Mockito.when(statementMock.executeUpdate()).thenThrow(new RuntimeException());
            Mockito.when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(statementMock);
        } catch (SQLException e) {
            Assert.fail();
        }
        Assert.assertEquals(null, listConversations.list(incompleteMap, contextMock));
    }

    @Test()
    public void testCompleteInputNoResults() throws SQLException {
        HashMap completeMap = getSampleMap();
        try {
            // Mocking necessary connection elements
            PreparedStatement psMock = Mockito.mock(PreparedStatement.class);
            ResultSet rsMock = Mockito.mock(ResultSet.class);
            Mockito.when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(psMock);
            Mockito.when(psMock.executeQuery()).thenReturn(rsMock);
            Mockito.when(rsMock.next()).thenReturn(false);
        } catch (SQLException e) {
            Assert.fail();
        }
        ListConversations listConversations = new ListConversations(connectionMock);
        Assert.assertNotNull(listConversations.list(completeMap, contextMock));
    }

    @Test()
    public void testConnectionRobustness() throws SQLException {
        HashMap completeMap = getSampleMap();

        // Mocking necessary connection elements
        PreparedStatement psMock = Mockito.mock(PreparedStatement.class);
        ResultSet rsMock = Mockito.mock(ResultSet.class);
        Mockito.when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(psMock);
        Mockito.when(psMock.executeQuery()).thenReturn(rsMock);
        Mockito.when(rsMock.next()).thenThrow(new SQLException());

        ListConversations listConversations = new ListConversations(connectionMock);
        ListConversations.ConversationListResponse response = listConversations.list(completeMap, contextMock);
        Assert.assertNull(response);

        // Asserts that close() has been called at least once
        Mockito.verify(connectionMock).close();
    }

    @Test()
    public void testCompleteInputOneToOneResult() throws SQLException {
        HashMap completeMap = getSampleMap();
        try {
            // Mocking necessary connection elements
            PreparedStatement psMock = Mockito.mock(PreparedStatement.class);
            ResultSet rsMock = Mockito.mock(ResultSet.class);
            Mockito.when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(psMock);
            Mockito.when(psMock.executeQuery()).thenReturn(rsMock);
            Mockito.when(rsMock.next())
                    .thenReturn(true)
                    .thenReturn(false)
                    .thenReturn(true)
                    .thenReturn(false);
            Mockito.when(rsMock.getString(1)).thenReturn("12345").thenReturn("test-id").thenReturn("test-name");
            Mockito.when(rsMock.getTimestamp(2)).thenReturn(new Timestamp(1L));
            Mockito.when(rsMock.getInt(3)).thenReturn(0);
        } catch (SQLException e) {
            Assert.fail();
        }
        ListConversations listConversations = new ListConversations(connectionMock);
        ListConversations.ConversationListResponse response = listConversations.list(completeMap, contextMock);
        Assert.assertNotNull(response);
        Assert.assertEquals("test-id", response.getConversationList()[0].getConverserID());
    }

    @Test()
    public void testCompleteInputSupportGroupResult() throws SQLException {
        HashMap completeMap = getSampleMap();
        try {
            // Mocking necessary connection elements
            PreparedStatement psMock = Mockito.mock(PreparedStatement.class);
            ResultSet rsMock = Mockito.mock(ResultSet.class);
            Mockito.when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(psMock);
            Mockito.when(psMock.executeQuery()).thenReturn(rsMock);
            Mockito.when(rsMock.next())
                    .thenReturn(true)
                    .thenReturn(false)
                    .thenReturn(true)
                    .thenReturn(true)
                    .thenReturn(false);
            Mockito.when(rsMock.getString(1)).thenReturn("12345").thenReturn("test-id").thenReturn("test-id2").thenReturn("test-name");
            Mockito.when(rsMock.getTimestamp(2)).thenReturn(new Timestamp(1L));
            Mockito.when(rsMock.getInt(3)).thenReturn(0);
        } catch (SQLException e) {
            Assert.fail();
        }
        ListConversations listConversations = new ListConversations(connectionMock);
        ListConversations.ConversationListResponse response = listConversations.list(completeMap, contextMock);
        Assert.assertNotNull(response);
        Assert.assertEquals("N/A", response.getConversationList()[0].getConverserID());
    }
}
