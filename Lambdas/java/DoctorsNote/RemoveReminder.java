package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.Map;

/*
 * A Lambda handler for removing reminders from a user.
 *
 * Expects: A JSON body with the following fields: reminderID (String)
 * Returns: TBD
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */

public class RemoveReminder implements RequestHandler<Map<String,Object>, ReminderRemover.RemoveReminderResponse> {
    @Override
    public ReminderRemover.RemoveReminderResponse handleRequest(Map<String,Object> inputMap, Context context) {
        // Establish connection with MariaDB
        ReminderRemover remover = makeReminderRemover();
        ReminderRemover.RemoveReminderResponse response = remover.remove(inputMap, context);
        if (response == null) {
            System.out.println("RemoveReminder: ReminderRemover returned null");
            throw new RuntimeException("Server experienced an error");
        }
        System.out.println("RemoveReminder: ReminderRemover returned valid response");
        return response;
    }

    public ReminderRemover makeReminderRemover() {
        System.out.println("RemoveReminder: Instantiating ReminderRemover");
        return new ReminderRemover(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("RemoveReminder: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
