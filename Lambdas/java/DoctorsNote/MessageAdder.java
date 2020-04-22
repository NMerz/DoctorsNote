package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.google.gson.Gson;

import javax.naming.ServiceUnavailableException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
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
    private final String addMessageFormatString = "INSERT INTO Message (sender, timeCreated, conversationID, contentType, senderContent, receiverContent, adminContent) VALUES (?, ?, ?, ?, ?, ?, ?);";
    private final String incrementMessagesSentString = "UPDATE Metrics SET value = value + 1 WHERE name = 'messagesSent';";
    private final String incrementMessagesFailedString = "UPDATE Metrics SET value = value + ? WHERE name = 'messagesFailed';";
    Connection dbConnection;

    public MessageAdder(Connection dbConnection) { this.dbConnection = dbConnection; }

    public AddMessageResponse add(Map<String,Object> inputMap, Context context) throws SQLException {
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
            statement.setString(1, (String)((Map<String,Object>) inputMap.get("context")).get("sub"));
            statement.setTimestamp(2, new java.sql.Timestamp(Instant.now().toEpochMilli()));
            statement.setLong(3, Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("conversationID").toString()));
            statement.setLong(4, Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("contentType").toString()));
            statement.setString(5, ((Map<String,Object>) inputMap.get("body-json")).get("senderContent").toString());
            statement.setString(6, ((Map<String,Object>) inputMap.get("body-json")).get("receiverContent").toString());
            statement.setString(7, ((Map<String,Object>) inputMap.get("body-json")).get("adminContent").toString());

            System.out.println("MessageAdder: statement: " + statement.toString());
            int ret = statement.executeUpdate();

            if (ret == 1) {
                System.out.println("MessageAdder: Update successful");

                System.out.println("MessageAdder: Incrementing metric messagesSent by 1");
                PreparedStatement messagesSentStatement = dbConnection.prepareStatement(incrementMessagesSentString);
                messagesSentStatement.executeUpdate();

                int nFailures;

                try {
                    nFailures = Integer.parseInt(((Map<String,Object>) inputMap.get("body-json")).get("numFails").toString());
                } catch (Exception e) {
                    nFailures = 0;
                }

                System.out.println("MessageAdder: Incrementing metric messagesFailed by " + nFailures);

                PreparedStatement messagesFailureStatement = dbConnection.prepareStatement(incrementMessagesFailedString);
                messagesFailureStatement.setInt(1, nFailures);
                messagesFailureStatement.executeUpdate();
            } else {
                System.out.println(String.format("MessageAdder: Update failed (%d)", ret));
                throw new ServiceUnavailableException("Unable to update database");
            }

            // Serialize and return an empty response object
            return new AddMessageResponse();
        } catch (Exception e) {
            System.out.println("MessageAdder: Exception encountered: " + e.toString());
            return null;
        } finally {
            dbConnection.close();
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
