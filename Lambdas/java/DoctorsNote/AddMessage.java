package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.google.gson.Gson;

import java.io.IOException;
import java.util.Date;
import java.sql.*;
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
public class AddMessage implements RequestHandler<Map<String,Object>, Object> {
    private final String addMessageFormatString = "INSERT INTO Message (content, sender, timeCreated, conversationID, recipient) VALUES (\'%s\', \'%s\', \'%s\', \'%s\', '000000000');";

    @Override
    public Object handleRequest(Map<String,Object> jsonString, Context context) {
        try {
            Map<String, Object> body = (Map<String,Object>)jsonString.get("body");
            String conversationId = (body).get("conversationId").toString();
            String content = (body).get("content").toString();
            String senderId = (body).get("senderId").toString();
            AddMessageRequest request = new AddMessageRequest(conversationId, content, senderId);

            // Establish connection with MariaDB
            Connection connection = getConnection();

            // Write to database (note: recipientId is intentionally omitted since it is unnecessary for future ops)
            Statement statement = connection.createStatement();
            String writeRowString = String.format(addMessageFormatString,
                    request.getContent(),
                    request.getSenderId(),
                    (new java.sql.Timestamp((new Date()).getTime())).toString(),
                    request.getConversationId());
            statement.executeUpdate(writeRowString);

            // Disconnect connection with shortest lifespan possible
            connection.close();

            // Serialize and return an empty response object
            return new AddMessageResponse();
        } catch (Exception e) {
            return null;
        }
    }

    private Connection getConnection() {
        try {
            DBCredentialsProvider dbCP = new DBCredentialsProvider();
            Class.forName(dbCP.getDBDriver());     // Loads and registers the driver
            return DriverManager.getConnection(dbCP.getDBURL(),
                    dbCP.getDBUsername(),
                    dbCP.getDBPassword());
        } catch (IOException | SQLException | ClassNotFoundException e) {
            throw new NullPointerException("Failed to load connection in AddMessage:getConnection()");
        }
    }

    private class AddMessageRequest {
        private String conversationId;
        private String content;
        private String senderId;

        public AddMessageRequest(String conversationId, String content, String senderId) {
            this.conversationId = conversationId;
            this.content = content;
            this.senderId = senderId;
        }

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

    private class AddMessageResponse {
        // No payload necessary
    }

    public static void main(String[] args) throws IllegalStateException {
        throw new IllegalStateException();
    }
}
