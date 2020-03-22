package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Map;

/*
 * Logic to process removing a reminder from the database.
 * NOTE: The passed connection will be closed
 */

public class ReminderRemover {
    private final String removeReminderFormatString = "DELETE FROM Reminder WHERE reminderID = ?;";
    Connection dbConnection;

    public ReminderRemover(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public RemoveReminderResponse remove(Map<String, Object> inputMap, Context context) {
        try {
            System.out.println("Preparing to remove reminder with id " + ((Map<String,Object>) inputMap.get("body-json")).get("reminderID"));
            PreparedStatement statement = dbConnection.prepareStatement(removeReminderFormatString);
            statement.setString(1, (String)((Map<String,Object>) inputMap.get("body-json")).get("reminderID"));
            System.out.println(statement);
            int res = statement.executeUpdate();
            System.out.println("statement.executeUpdate returned " + res);

            // Disconnect connection with shortest lifespan possible
            dbConnection.close();
            System.out.println("Connection closed");

            // Serialize and return an empty response object
            return new RemoveReminderResponse();
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public class RemoveReminderResponse {
        // No payload necessary
    }
}
