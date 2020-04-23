import DoctorsNote.MessageAdder;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Test;
import org.junit.Assert;
import org.mockito.Mockito;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.HashMap;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

public class MessageAdderTest {
    Connection connectionMock = mock(Connection.class);

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("senderContent", "Test Message");
        jsonBody.put("receiverContent", "Test Message");
        jsonBody.put("adminContent", "Test Message");
        jsonBody.put("contentType", 0L);
//        jsonBody.put("senderId", "0000000001");
        jsonBody.put("conversationID", 1L);
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "sub-id123"); //Note: not an accurate length for sample id
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testEmptyInputs() throws SQLException {
        MessageAdder messageAdder = new MessageAdder(connectionMock);
        Assert.assertEquals(null, messageAdder.add(new HashMap<>(), mock(Context.class)));
    }

    @Test()
    public void testMissingInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("content");
        MessageAdder messageAdder = new MessageAdder(connectionMock);
        Assert.assertEquals(null, messageAdder.add(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testBadInput() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).put("content", 1);
        MessageAdder messageAdder = new MessageAdder(connectionMock);
        Assert.assertEquals(null, messageAdder.add(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testConnectionError() throws SQLException {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("content");
        MessageAdder messageAdder = new MessageAdder(connectionMock);
        try {
            PreparedStatement statementMock = Mockito.mock(PreparedStatement.class);
            Mockito.when(statementMock.executeUpdate()).thenThrow(new RuntimeException());
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(statementMock);
        } catch (SQLException e) {
            Assert.fail();
        }
        Assert.assertEquals(null, messageAdder.add(incompleteMap, mock(Context.class)));
    }

    @Test()
    public void testCompleteInput() throws SQLException {
        PreparedStatement psMock = Mockito.mock(PreparedStatement.class);
        HashMap completeMap = getSampleMap();
        try {
            when(connectionMock.prepareStatement(Mockito.anyString())).thenReturn(psMock);
            when(psMock.executeUpdate()).thenReturn(1);

        } catch (SQLException e) {
            Assert.fail();
        }
        MessageAdder messageAdder = new MessageAdder(connectionMock);
        Assert.assertNotNull(messageAdder.add(completeMap, mock(Context.class)));
    }
}
