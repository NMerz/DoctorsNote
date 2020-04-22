package DoctorsNote;

/*
 * Logic to get conversation details by id. This only applies to support groups.
 * NOTE: The passed connection will be closed
 */

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Map;

public class ConversationGetter {
    private final String getConversationFormatString = "SELECT conversationName, lastMessageTime, status, adminPublicKey, description FROM Conversation WHERE conversationID = ?;";
    private final String getNMembersFormatString = "SELECT count(*) FROM Conversation_has_User WHERE conversationID = ?;";
    Connection dbConnection;

    public ConversationGetter(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public Conversation get(Map<String, Object> inputMap, Context context) throws SQLException {
        try {
            String conversationId = (String)((Map<String,Object>) inputMap.get("body-json")).get("conversationId");

            PreparedStatement statement = dbConnection.prepareStatement(getConversationFormatString);
            System.out.println("ConversationGetter: Getting details of conversation " + conversationId);
            statement.setString(1, conversationId);
            System.out.println("ConversationGetter: statement: " + statement);
            ResultSet conversationRS = statement.executeQuery();

            // Processing results
            conversationRS.next();

            String conversationName = conversationRS.getString(1);
            String converserName = "N/A";
            long lastMessageTime = conversationRS.getTimestamp(2).toInstant().toEpochMilli();
            int status = conversationRS.getInt(3);
            String adminPublicKey = conversationRS.getString(4);
            String description = conversationRS.getString(5);

            // Getting the number of members of the support group
            PreparedStatement nMembersStatement = dbConnection.prepareStatement(getNMembersFormatString);
            nMembersStatement.setString(1, conversationId);
            ResultSet nMembersRS = nMembersStatement.executeQuery();
            nMembersRS.next();
            int numMembers = nMembersRS.getInt(1);

            return new Conversation(conversationName, conversationId, converserName, "N/A", adminPublicKey, status, lastMessageTime, numMembers, description);
        } catch (Exception e) {
            System.out.println("ConversationGetter: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }
}
