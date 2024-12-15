import DoctorsNote.Connector;
import DoctorsNote.MessageAdder;
import DoctorsNote.MessageRemover;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

/*
 * Note: These connections are live and will damage the database if done wrong
 */

public class MessageStatisticsTest {
    private final String addMessageFormatString = "INSERT INTO Message (content, sender, timeCreated, conversationID, contentType) VALUES (?, ?, ?, ?, ?);";
    private final String getMessageIdString = "SELECT messageID FROM Message WHERE sender = \"__veryfakesender\" AND conversationID = 0;";
    private final String getMessageStatsString = "SELECT * FROM Metrics";

    Connection connection;
    Context contextMock;
    MessageAdder adder;

    @Before
    public void before() throws SQLException {
        connection = Connector.getConnection("Lambdas/res/DBCredentials.tsv");
        adder = new MessageAdder(connection);

        contextMock = Mockito.mock(Context.class);
    }

    private HashMap getMessageMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("senderContent", "Test Message");
        jsonBody.put("receiverContent", "Test Message");
        jsonBody.put("adminContent", "Test Message");
        jsonBody.put("contentType", 0L);
        jsonBody.put("conversationID", 0L);
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "__veryfakesender"); //Note: not an accurate length for sample id
        topMap.put("context", context);
        return topMap;
    }

    // Returns messages sent at index 0 and messages failed at index 1
    private int[] getMessageStats() throws SQLException {
        Connection dbConnection = Connector.getConnection("Lambdas/res/DBCredentials.tsv");
        PreparedStatement ps = dbConnection.prepareStatement(getMessageStatsString);
        ResultSet rs = ps.executeQuery();

        int sent = 0, failed = 0;
        while (rs.next()) {
            if (rs.getString(1).equals("messagesSent")) {
                sent = rs.getInt(2);
            } else if (rs.getString(1).equals("messagesFailed")) {
                failed = rs.getInt(2);
            }
        }

        dbConnection.close();

        return new int[]{sent, failed};
    }

    private void sendMessage(HashMap map) throws SQLException {
        MessageAdder.AddMessageResponse response = adder.add(map, contextMock);
        Assert.assertNotNull(response);
    }

    @Test
    public void testNoFailed() throws SQLException {
        HashMap map = getMessageMap();

        int[] oldStats = getMessageStats();
        sendMessage(map);
        int[] newStats = getMessageStats();

        Assert.assertNotEquals(newStats[0] - oldStats[0], 0);
        Assert.assertEquals(newStats[1] - oldStats[1], 0);
    }




    @Test
    public void testOneFailed() throws SQLException {
        HashMap map = getMessageMap();
        ((HashMap) map.get("body-json")).put("numFails", "1");

        int[] oldStats = getMessageStats();
        sendMessage(map);
        int[] newStats = getMessageStats();

        Assert.assertNotEquals(newStats[0] - oldStats[0], 0);
        Assert.assertNotEquals(newStats[1] - oldStats[1], 0);
    }
}
