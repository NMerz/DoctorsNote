package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.google.gson.Gson;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Date;
import java.util.Map;

/*
 * A Lambda handler for adding messages to a conversation on behalf of a user.
 *
 * The conversation must exist already or an exception will be encountered.
 *
 * Expects: A JSON string that maps to a POJO of type AddMessageRequest.
 * Returns: A JSON string that maps from a POJO of type AddMessageResponse.
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */
public class MessageAdder {
    private final String addMessageFormatString = "INSERT INTO Message (content, sender, timeCreated, conversationID) VALUES (?, ?, ?, ?);";
    Connection dbConnection;

    public MessageAdder(Connection dbConnection) { this.dbConnection = dbConnection; }

    public AddMessageResponse add(Map<String,Object> inputMap, Context context) {
        try {

            // Write to database (note: recipientId is intentionally omitted since it is unnecessary for future ops)
            PreparedStatement statement = dbConnection.prepareStatement(addMessageFormatString);
            statement.setString(1, (String)((Map<String,Object>) inputMap.get("body-json")).get("content"));
            statement.setString(2, (String)((Map<String,Object>) inputMap.get("body-json")).get("senderId"));
            statement.setString(2, (new java.sql.Timestamp((new Date()).getTime())).toString());
            statement.setString(4, (String)((Map<String,Object>) inputMap.get("body-json")).get("conversationId"));
            System.out.println("MessageAdder: statement: " + statement.toString());
            int ret = statement.executeUpdate();

            if (ret == 0) {
                System.out.println("MessageAdder: Update successful");
            } else {
                System.out.println(String.format("MessageAdder: Update failed (%d)", ret));
            }

            // Disconnect connection with shortest lifespan possible
            dbConnection.close();

            // Serialize and return an empty response object
            return new AddMessageResponse();
        } catch (Exception e) {
            System.out.println("MessageAdder: Exception encountered: " + e.toString());
            return null;
        }
    }

    private class AddMessageRequest {
        private String conversationId;
        private String content;
        private String senderId;

        public String getConversationId() {
            return conversationId;
        }

        public void setConversationId(String conversationId) {
            this.conversationId = conversationId;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public String getSenderId() {
            return senderId;
        }

        public void setSenderId(String senderId) {
            this.senderId = senderId;
        }
    }

    public class AddMessageResponse {
        // No payload necessary
    }
}
