package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Map;

public class ReminderPurger {
    private final String purgeReminderFormatString = "DELETE FROM Reminder WHERE alertTime < ?;";
    Connection dbConnection;

    public ReminderPurger(Connection dbConnection) { this.dbConnection = dbConnection; }

    public PurgeReminderResponse purge(Map<String, Object> inputMap, Context context) throws SQLException {
        try {
            long currentEpochTime = Instant.now().getEpochSecond();
            // Note: There are ~604800 seconds in a week (leap second precision not necessary here)
            long weekAgoEpochTime = currentEpochTime < 604800L ? 0L : currentEpochTime - 604800L;   // To prevent potential underflow
            System.out.println("ReminderPurger: Purging reminders older than " + weekAgoEpochTime);

            PreparedStatement statement = dbConnection.prepareStatement(purgeReminderFormatString);
            statement.setTimestamp(1, new Timestamp(weekAgoEpochTime));
            int ret = statement.executeUpdate();

            if (ret > 0) {
                System.out.println("ReminderPurger: Update successful");
            } else {
                System.out.println(String.format("ReminderPurger: Update failed (%d)", ret));
            }

            // Serialize and return an empty response object
            return new PurgeReminderResponse();
        } catch (Exception e) {
            System.out.println("ReminderPurger: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    public class PurgeReminderResponse {
        // No payload necessary
    }
}
