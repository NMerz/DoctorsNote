package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Map;

public class MessagePurger {
    private final String purgeMessageFormatString = "DELETE FROM Message WHERE messageID >= 0 AND timeCreated < ?;";
    Connection dbConnection;

    public MessagePurger(Connection dbConnection) { this.dbConnection = dbConnection; }

    public PurgeMessageResponse purge(Map<String, Object> inputMap, Context context) throws SQLException {
        try {
            long currentEpochTime = Instant.now().getEpochSecond();
            // Note: There are ~2419200 seconds in four weeks (leap second precision not necessary here)
            long fourWeeksAgoEpochTime = currentEpochTime < 2419200L ? 0L : currentEpochTime - 2419200L;   // To prevent potential underflow
            System.out.println("MessagePurger: Purging messages older than " + fourWeeksAgoEpochTime);

            PreparedStatement statement = dbConnection.prepareStatement(purgeMessageFormatString);
            statement.setTimestamp(1, new Timestamp(fourWeeksAgoEpochTime * 1000L));
            System.out.println("MessagePurger: statement: " + statement);
            int ret = statement.executeUpdate();

            if (ret == 0) {
                System.out.println("MessagePurger: Update successful");
            } else {
                System.out.println(String.format("MessagePurger: Update failed (%d)", ret));
            }

            // Serialize and return an empty response object
            return new PurgeMessageResponse();
        } catch (Exception e) {
            System.out.println("MessagePurger: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    public class PurgeMessageResponse {
        // No payload necessary
    }
}
