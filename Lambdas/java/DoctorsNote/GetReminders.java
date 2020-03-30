package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.Map;

/*
 * A Lambda handler for getting reminders for a user.
 *
 * Expects: A JSON body with the following fields: since (long, representing epoch time)
 * Returns: A response object containing responseID (String), content (String), alertTime (long, representing epoch times)
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */

public class GetReminders implements RequestHandler<Map<String,Object>, ReminderGetter.GetReminderResponse> {
    @Override
    public ReminderGetter.GetReminderResponse handleRequest(Map<String,Object> inputMap, Context context) {
        // Establish connection with MariaDB
        ReminderGetter getter = makeReminderGetter();
        ReminderGetter.GetReminderResponse response = getter.get(inputMap, context);
        if (response == null) {
            System.out.println("GetReminders: ReminderGetter returned null");
            throw new RuntimeException("Server experienced an error");
        }
        System.out.println("GetReminders: ReminderGetter returned valid response");
        return response;
    }

    public ReminderGetter makeReminderGetter() {
        System.out.println("GetReminders: Instantiating ReminderGetter");
        return new ReminderGetter(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("GetReminders: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
