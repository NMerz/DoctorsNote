package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for adding reminders for a user.
 *
 * Expects: A JSON body with the following fields: content (String), remindee (String), creator (String), timeCreated (long), alertTime (long)
 * Returns: TBD
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */

public class AddReminder implements RequestHandler<Map<String,Object>, ReminderAdder.AddReminderResponse> {

    @Override
    public ReminderAdder.AddReminderResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            // Establish connection with MariaDB
            ReminderAdder adder = makeReminderAdder();
            ReminderAdder.AddReminderResponse response = adder.add(inputMap, context);
            if (response == null) {
                System.out.println("AddReminder: ReminderAdder returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("AddReminder: ReminderAdder returned valid response");
            return response;
        }  catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("AddReminder: Could not close the database connection");
            return null;
        }
    }

    public ReminderAdder makeReminderAdder() {
        System.out.println("AddReminder: Instantiating ReminderAdder");
        return new ReminderAdder(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("AddReminder: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
