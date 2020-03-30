package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.Map;

/*
 * Logic to process adding a calendar event to the database.
 * NOTE: The passed connection will be closed
 */

public class EventAdder {
    private final String addEventFormatString = "INSERT INTO Calendar (startTime, endTime, location, title, description, userID) VALUES (?, ?, ?, ?, ?, ?);";
    Connection dbConnection;

    public EventAdder(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public AddEventResponse add(Map<String, Object> inputMap, Context context) {
        try {
            System.out.println("EventAdder: Adding reminder on behalf of " + context.getIdentity().getIdentityId());

            PreparedStatement statement = dbConnection.prepareStatement(addEventFormatString);
            statement.setTimestamp(1, new Timestamp(Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("startTime").toString())));
            statement.setTimestamp(2, new Timestamp(Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("endTime").toString())));
            statement.setString(3, (String)((Map<String,Object>) inputMap.get("body-json")).get("location"));
            statement.setString(4, (String)((Map<String,Object>) inputMap.get("body-json")).get("title"));
            statement.setString(5, (String)((Map<String,Object>) inputMap.get("body-json")).get("description"));
            statement.setString(6, context.getIdentity().getIdentityId());
            System.out.println("EventAdder: statement: " + statement);
            int ret = statement.executeUpdate();

            if (ret == 0) {
                System.out.println("EventAdder: Update successful");
            } else {
                System.out.println(String.format("EventAdder: Update failed (%d)", ret));
            }

            // Disconnect connection with shortest lifespan possible
            dbConnection.close();

            // Serialize and return an empty response object
            return new AddEventResponse();
        } catch (Exception e) {
            System.out.println("EventAdder: Exception encountered: " + e.getMessage());
            return null;
        }
    }

    public class AddEventResponse {
        // No payload necessary
    }
}
