package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Map;

/*
 * Logic to process removing a calendar event from the database.
 * NOTE: The passed connection will be closed
 */

public class EventRemover {
    private final String removeEventFormatString = "DELETE FROM Calendar WHERE appointmentID = ?;";
    Connection dbConnection;

    public EventRemover(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public RemoveEventResponse remove(Map<String, Object> inputMap, Context context) throws SQLException {
        try {
            String userId = (String)((Map<String,Object>) inputMap.get("context")).get("sub");
            System.out.println("EventRemover: Removing event on behalf of " + userId);

            PreparedStatement statement = dbConnection.prepareStatement(removeEventFormatString);
            statement.setInt(1, Integer.parseInt(((Map<String,Object>) inputMap.get("body-json")).get("appointmentID").toString()));
            System.out.println("EventRemover: statement: " + statement);
            int ret = statement.executeUpdate();

            if (ret > 0) {
                System.out.println("EventRemover: Update successful");
            } else {
                System.out.println(String.format("EventRemover: Update failed (%d)", ret));
            }

            // Serialize and return an empty response object
            return new RemoveEventResponse();
        } catch (Exception e) {
            System.out.println("EventRemover: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    public class RemoveEventResponse {
        // No payload necessary
    }
}
