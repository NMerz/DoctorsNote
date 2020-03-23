package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.Map;

/*
 * A Lambda handler for purging reminders from a user.
 * This Lambda should be called from a cron job within the AWS Console and should not have an associated API.
 *
 * Expects: Any valid input (may also be null).
 * Returns: An empty response object.
 *
 * Error Handling: Throws a RuntimeException if an unrecoverable error is encountered
 */

public class PurgeReminders implements RequestHandler<Map<String,Object>, ReminderPurger.PurgeReminderResponse> {

    @Override
    public ReminderPurger.PurgeReminderResponse handleRequest(Map<String,Object> inputMap, Context context) {
        // Establish connection with MariaDB
        ReminderPurger purger = new ReminderPurger(Connector.getConnection());
        ReminderPurger.PurgeReminderResponse response = purger.purge(inputMap, context);
        if (response == null) {
            throw new RuntimeException("Server experienced an error");
        }
        return response;
    }

    public static void main(String[] args) throws IllegalStateException {
        throw new IllegalStateException();
    }
}
