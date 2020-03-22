package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Map;

public class ReminderPurger {
    private final String purgeReminderFormatString = "DELETE FROM Reminder WHERE alertTime < ?;";
    Connection dbConnection;

    public ReminderPurger(Connection dbConnection) { this.dbConnection = dbConnection; }

    public PurgeReminderResponse purge(Map<String, Object> inputMap, Context context) {
        try {
            long currentEpochTime = Instant.now().getEpochSecond();
            // Note: There are ~604800 seconds in a week (leap second precision not necessary here)
            long weekAgoEpochTime = currentEpochTime < 604800L ? 0L : currentEpochTime - 604800L;   // To prevent potential underflow
            System.out.println("Purging reminders older than " + weekAgoEpochTime);

            PreparedStatement statement = dbConnection.prepareStatement(purgeReminderFormatString);
            statement.setTimestamp(1, new Timestamp(weekAgoEpochTime));
            int res = statement.executeUpdate();

            System.out.println("Purge executed with return value " + res);

            // Disconnect connection with shortest lifespan possible
            dbConnection.close();

            // Serialize and return an empty response object
            return new PurgeReminderResponse();
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public class PurgeReminderResponse {
        // No payload necessary
    }
}
