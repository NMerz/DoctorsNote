package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.*;
import java.util.Map;

/*
 * Logic to process adding a reminder to the database.
 * NOTE: The passed connection will be closed
 */

public class ReminderAdder {
    private final String addReminderFormatString = "INSERT INTO Reminder (content, remindedID, creatorID, timeCreated, alertTime) VALUES (?, ?, ?, ?, ?);";
    Connection dbConnection;

    public ReminderAdder(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public ReminderAdder.AddReminderResponse add(Map<String, Object> inputMap, Context context) {
        try {
            PreparedStatement statement = dbConnection.prepareStatement(addReminderFormatString);
            statement.setString(1, (String)((Map<String,Object>) inputMap.get("body-json")).get("content"));
            statement.setString(2, (String)((Map<String,Object>) inputMap.get("body-json")).get("remindee"));
            statement.setString(3, (String)((Map<String,Object>) inputMap.get("context")).get("sub"));
            statement.setTimestamp(4, new Timestamp(Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("timeCreated").toString())));
            statement.setTimestamp(5, new Timestamp(Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("alertTime").toString())));
            System.out.println(statement);
            statement.executeUpdate();
            //statement.execute(addReminderFormatString);
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
