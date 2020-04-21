import DoctorsNote.ConversationJoiner;
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

public class ConversationJoinerTest {
    Connection connectionMock = mock(Connection.class);

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("userId", "102");
        jsonBody.put("conversationId", "04");
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "sub-id123");   // Note: not an accurate length for sample id
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testEmptyInputs() throws SQLException {
        ConversationJoiner conversationJoiner = new ConversationJoiner(connectionMock);
        Assert.assertEquals(null, conversationJoiner.join(new HashMap<>(), mock(Context.class)));
    }

    @Test()
    public void testMissingInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("userId");
        ConversationJoiner conversationJoiner = new ConversationJoiner(connectionMock);
        Assert.assertEquals(null, conversationJoiner.join(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testBadInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).put("userId", null);
        ConversationJoiner conversationJoiner = new ConversationJoiner(connectionMock);
        Assert.assertEquals(null, conversationJoiner.join(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testConnectionError() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("userId");
        ConversationJoiner conversationJoiner = new ConversationJoiner(connectionMock);
        try {
            PreparedStatement statementMock = Mockito.mock(PreparedStatement.class);
            Mockito.when(statementMock.executeUpdate()).thenThrow(new RuntimeException());
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(statementMock);
        } catch (SQLException e) {
            Assert.fail();
        }
        Assert.assertEquals(null, conversationJoiner.join(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testCompleteInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        try {
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(Mockito.mock(PreparedStatement.class));
        } catch (SQLException e) {
            Assert.fail();
        }
        ConversationJoiner conversationJoiner = new ConversationJoiner(connectionMock);
        Assert.assertNotNull(conversationJoiner.join(incompleteMap, mock(Context.class)));
    }
}
