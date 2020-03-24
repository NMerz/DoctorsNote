package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

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
        // Establish connection with MariaDB
        ReminderAdder adder = makeReminderAdder();
        ReminderAdder.AddReminderResponse response = adder.add(inputMap, context);
        if (response == null) {
            throw new RuntimeException("Server experienced an error");
        }
        return response;
    }

    public ReminderAdder makeReminderAdder() {
        return new ReminderAdder(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        throw new IllegalStateException();
    }
}
