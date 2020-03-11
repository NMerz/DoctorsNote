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
public class AddMessage implements RequestHandler<Map<String,Object>, AddMessage.AddMessageResponse> {
    private final String addMessageFormatString = "INSERT INTO Message (content, sender, timeCreated, conversationID, recipient) VALUES (\'%s\', \'%s\', \'%s\', \'%s\', '000000000');";

    @Override
    public AddMessageResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            // Converting the passed JSON string into a POJO
            Gson gson = new Gson();
            //AddMessageRequest request = gson.fromJson(jsonString, AddMessage.AddMessageRequest.class);
            // Establish connection with MariaDB
            DBCredentialsProvider dbCP;
            Connection connection = getConnection();

            // Write to database (note: recipientId is intentionally omitted since it is unnecessary for future ops)
            Statement statement = connection.createStatement();
            String writeRowString = String.format(addMessageFormatString,
                    ((Map<String,Object>) inputMap.get("body-json")).get("content"),
                    ((Map<String,Object>) inputMap.get("body-json")).get("senderID"),
                    (new java.sql.Timestamp((new Date()).getTime())).toString(),
                    ((Map<String,Object>) inputMap.get("body-json")).get("conversationID"));
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

    public static void main(String[] args) throws IllegalStateException {
        throw new IllegalStateException();
    }
}
