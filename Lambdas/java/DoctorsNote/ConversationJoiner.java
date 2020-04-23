package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;

public class ConversationJoiner {
    private final String joinConversationFormatString = "INSERT INTO Conversation_has_User (conversationID, userID) VALUES (?, ?);";
    Connection dbConnection;

    public ConversationJoiner(Connection dbConnection) { this.dbConnection = dbConnection; }

    public JoinConversationResponse join(Map<String, Object> inputMap, Context context) throws SQLException {
        try {

            String conversationId = ((Map<String,Object>) inputMap.get("body-json")).get("conversationId").toString();
            String userId = (String)((Map<String,Object>) inputMap.get("context")).get("sub");

            System.out.println("ConversationJoiner: Adding " + userId + " to " + conversationId);

            PreparedStatement statement = dbConnection.prepareStatement(joinConversationFormatString);
            statement.setString(1, conversationId);
            statement.setString(2, userId);
            System.out.println("ConversationJoiner: statement: " + statement.toString());
            int ret = statement.executeUpdate();

            if (ret > 0) {
                System.out.println("ConversationJoiner: Update successful");
            } else {
                System.out.println(String.format("ConversationJoiner: Update failed (%d)", ret));
            }

            // Serialize and return an empty response object
            return new JoinConversationResponse();
        } catch (Exception e) {
            System.out.println("ConversationJoiner: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    public class JoinConversationResponse {
        // No payload necessary
    }
}
