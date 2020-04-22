package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;

public class ConversationLeaver {
    private final String leaveConversationFormatString = "DELETE FROM Conversation_has_User WHERE conversationID = ? AND userID = ?;";
    Connection dbConnection;

    public ConversationLeaver(Connection dbConnection) { this.dbConnection = dbConnection; }

    public LeaveConversationResponse leave(Map<String, Object> inputMap, Context context) throws SQLException {
        try {

            String conversationId = (String)((Map<String,Object>) inputMap.get("body-json")).get("conversationId");
            String userId = (String)((Map<String,Object>) inputMap.get("context")).get("sub");

            System.out.println("ConversationLeaver: Removing " + userId + " from " + conversationId);

            PreparedStatement statement = dbConnection.prepareStatement(leaveConversationFormatString);
            statement.setString(1, conversationId);
            statement.setString(2, userId);
            System.out.println("ConversationLeaver: statement: " + statement.toString());
            int ret = statement.executeUpdate();

            if (ret == 0) {
                System.out.println("ConversationLeaver: Update successful");
            } else {
                System.out.println(String.format("ConversationLeaver: Update failed (%d)", ret));
                throw new RuntimeException(String.format("ConversationLeaver: Update failed (%d)", ret));
            }

            // Serialize and return an empty response object
            return new LeaveConversationResponse();
        } catch (Exception e) {
            System.out.println("ConversationLeaver: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    public class LeaveConversationResponse {
        // No payload necessary
    }
}
