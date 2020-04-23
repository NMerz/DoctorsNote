package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;

/*
 * Logic to process removing a message from the database by id.
 * NOTE: The passed connection will be closed
 */

public class MessageRemover {
    private final String removeMessageFormatString = "DELETE FROM Message WHERE messageID = ?;";
    Connection dbConnection;

    public MessageRemover(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public RemoveMessageResponse remove(Map<String, Object> inputMap, Context context) throws SQLException {
        try {
            String userId = (String)((Map<String,Object>) inputMap.get("context")).get("sub");
            System.out.println("MessageRemover: Removing message on behalf of " + userId);

            PreparedStatement statement = dbConnection.prepareStatement(removeMessageFormatString);
            statement.setInt(1, Integer.parseInt((String)((Map<String,Object>) inputMap.get("body-json")).get("messageId")));
            System.out.println("MessageRemover: statement: " + statement);
            int ret = statement.executeUpdate();

            if (ret > 0) {
                System.out.println("MessageRemover: Update successful");
            } else {
                System.out.println(String.format("MessageRemover: Update failed (%d)", ret));
            }

            // Serialize and return an empty response object
            return new RemoveMessageResponse();
        } catch (Exception e) {
            System.out.println("MessageRemover: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    public class RemoveMessageResponse {
        // No payload necessary
    }
}
