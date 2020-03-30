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
    public void testEmptyInputs() {
        ListConversations listConversations = new ListConversations(connectionMock);
        Assert.assertEquals(null, listConversations.list(new HashMap<>(), contextMock));
    }

    @Test()
    public void testMissingInput() {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("context");
        ListConversations listConversations = new ListConversations(connectionMock);
        Assert.assertEquals(null, listConversations.list(incompleteMap, contextMock));
    }

    @Test()
    public void testBadInput() {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("context")).put("sub", 1);
        ListConversations listConversations = new ListConversations(connectionMock);
        Assert.assertEquals(null, listConversations.list(incompleteMap, contextMock));
    }

    @Test()
    public void testConnectionError() {
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
    public void testCompleteInput() {
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
}
