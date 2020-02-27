package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.google.gson.Gson;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.util.Map;

/*
 * A Lambda handler for creating a new conversation.
 *
 * Expects: A JSON string that maps to a POJO of type CreateConversationRequest
 * Returns: A JSON string that maps from a POJO of type CreateConversationResponse
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */
public class CreateConversation implements RequestHandler<Map<String,Object>, Object> {
    private final String addMessageFormatString = "INSERT INTO Conversation (conversationName, lastMessageTime) VALUES (\'%s\', \'%s\');";

    public CreateConversationResponse handleRequest(Map<String,Object> jsonString, Context context) {
        try {
            // NEEDS TO ADD TO THE CONVERSATION_HAS_USER TABLE TOO.
            // KIND OF USELESS RN.
            // TODO: ^^^^^^^^

            CreateConversationRequest request = new CreateConversationRequest(((Map<String,Object>)jsonString.get("body")).get("conversationName").toString());

            // Establish connection with MariaDB
            Connection connection = getConnection();

            // Write to database
            Statement statement = connection.createStatement();
            String writeRowString = String.format(addMessageFormatString,
                    request.getConversationName(),
                    (new java.sql.Timestamp((new Date()).getTime())).toString());
            statement.executeUpdate(writeRowString);

            // Disconnect connection with shortest lifespan possible
            connection.close();

            return new CreateConversationResponse();
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

    private class CreateConversationRequest {
        private String conversationName;

        public CreateConversationRequest(String conversationName) {
            this.conversationName = conversationName;
        }

        public String getConversationName() {
            return conversationName;
        }

        public void setConversationName(String conversationName) {
            this.conversationName = conversationName;
        }
    }

    private class CreateConversationResponse {
        // No payload necessary
    }

    public static void main(String[] args) {
        throw new IllegalStateException();
    }
}
