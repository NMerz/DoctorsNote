package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Map;

/*
 * Test class to test for SQL injection. Modeled after EventAdder.
 * NOTE: The passed connection will be closed
 */

public class BaitAdder {
    private final String addBaitFormatString = "INSERT INTO Bait (timeScheduled, content, withId, userId, status) VALUES (?, ?, ?, ?, ?);";
    Connection dbConnection;

    public BaitAdder(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public AddBaitResponse add(Map<String, Object> inputMap, Context context) throws SQLException {
        try {
            String userId = (String)((Map<String,Object>) inputMap.get("context")).get("sub");
            System.out.println("BaitAdder: Adding bait on behalf of " + userId);

            PreparedStatement statement = dbConnection.prepareStatement(addBaitFormatString);
            statement.setTimestamp(1, new Timestamp(Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("timeScheduled").toString())));
            statement.setString(2, (String)((Map<String,Object>) inputMap.get("body-json")).get("content"));
            statement.setString(3, (String)((Map<String,Object>) inputMap.get("body-json")).get("withID"));
            statement.setString(4, (String)((Map<String,Object>) inputMap.get("context")).get("sub"));
            statement.setInt(5, -1);
            System.out.println("BaitAdder: statement: " + statement);
            int ret = statement.executeUpdate();

            if (ret == 0) {
                System.out.println("BaitAdder: Update successful");
            } else {
                System.out.println(String.format("BaitAdder: Update failed (%d)", ret));
            }

            // Serialize and return an empty response object
            return new AddBaitResponse();
        } catch (Exception e) {
            System.out.println("BaitAdder: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    public class AddBaitResponse {
        // No payload necessary
    }
}
