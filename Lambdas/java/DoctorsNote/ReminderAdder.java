package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.Statement;
import java.util.Map;

/*
 * Logic to process adding a reminder to the database.
 * NOTE: The passed connection will be closed
 */

public class ReminderAdder {
    private final String addReminderFormatString = "INSERT INTO Reminder (content, remindee, creator, timeCreated, alertTime) VALUES (\'%s\', \'%s\', \'%s\', \'%s\', \'%s\');";
    Connection dbConnection;

    ReminderAdder(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public ReminderAdder.AddReminderResponse add(Map<String, Object> inputMap, Context context) {
        try {
            Statement statement = dbConnection.createStatement();
            String args[] = {(String)((Map<String,Object>) inputMap.get("body-json")).get("content"),
                    (String)((Map<String,Object>) inputMap.get("body-json")).get("remindee"),
                    (String)((Map<String,Object>) inputMap.get("context")).get("sub"),
                    ((Integer) ((Map<String,Object>) inputMap.get("body-json")).get("timeCreated")).toString(),
                    ((Integer) ((Map<String,Object>) inputMap.get("body-json")).get("alertTime")).toString()};
            statement.execute(addReminderFormatString, args);
            //statement.executeUpdate(writeRowString);

            // Disconnect connection with shortest lifespan possible
            dbConnection.close();

            // Serialize and return an empty response object
            return new AddReminderResponse();
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public class AddReminderResponse {
        // No payload necessary
    }
}
