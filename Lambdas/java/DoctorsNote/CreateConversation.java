package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.google.gson.Gson;

import java.io.IOException;
import java.sql.*;
import java.util.Date;

/*
 * A Lambda handler for creating a new conversation.
 *
 * Expects: A JSON string that maps to a POJO of type CreateConversationRequest
 * Returns: A JSON string that maps from a POJO of type CreateConversationResponse
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */
public class CreateConversation implements RequestHandler<String, String> {
    private final String addMessageFormatString = "INSERT INTO Conversation (conversationName, lastMessageTime, isSupportGroup) VALUES (?, ?, ?);";

    public String handleRequest(String jsonString, Context context) {
        try {
            // Converting the passed JSON string into a POJO
            Gson gson = new Gson();
            CreateConversationRequest request = gson.fromJson(jsonString, CreateConversationRequest.class);

            // Establish connection with MariaDB
            DBCredentialsProvider dbCP;
            Connection connection = getConnection();

            // Write to database
            PreparedStatement statement = connection.prepareStatement(addMessageFormatString);
            statement.setString(1, request.getConversationName());
            statement.setString(2, (new java.sql.Timestamp((new Date()).getTime())).toString());
            statement.setInt(3, 0);  // TODO: Update to pull from passed value; API not currently used so not a priority
            int res = statement.executeUpdate();

            // TODO: Update Conversation_has_User as well

            // Disconnect connection with shortest lifespan possible
            connection.close();

            return gson.toJson(new CreateConversationResponse());
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
