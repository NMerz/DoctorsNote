package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.google.gson.Gson;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.Instant;
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
    private final String addMessageFormatString = "INSERT INTO Message (content, sender, timeCreated, conversationID, contentType) VALUES (?, ?, ?, ?, ?);";
    Connection dbConnection;

    public MessageAdder(Connection dbConnection) { this.dbConnection = dbConnection; }

    public AddMessageResponse add(Map<String,Object> inputMap, Context context) {
        try {
            for (String key : ((Map<String,Object>)inputMap.get("context")).keySet()) {
                System.out.println("Key:" + key);
                System.out.println(((Map<String,Object>)inputMap.get("context")).get(key));
            }
            for (String key : ((Map<String,Object>)inputMap.get("body-json")).keySet()) {
                System.out.println("Key:" + key);
                System.out.println(((Map<String,Object>)inputMap.get("body-json")).get(key));
            }
            PreparedStatement statement = dbConnection.prepareStatement(addMessageFormatString);
            statement.setString(1, (String)((Map<String,Object>) inputMap.get("body-json")).get("content"));
            statement.setString(2, (String)((Map<String,Object>) inputMap.get("context")).get("sub"));
            statement.setTimestamp(3, new java.sql.Timestamp(Instant.now().toEpochMilli()));
            statement.setLong(4, Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("conversationID").toString()));
            statement.setLong(5, Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("contentType").toString()));
            System.out.println(statement);
            statement.executeUpdate();

            // Disconnect connection with shortest lifespan possible
            dbConnection.close();

            // Serialize and return an empty response object
            return new AddMessageResponse();
        } catch (Exception e) {
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
