package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for purging messages from the database.
 * This Lambda should be called from a cron job within the AWS Console and should not have an associated API.
 *
 * Expects: Any valid input (may also be null).
 * Returns: An empty response object.
 *
 * Error Handling: Throws a RuntimeException if an unrecoverable error is encountered
 */

public class PurgeMessages implements RequestHandler<Map<String,Object>, MessagePurger.PurgeMessageResponse> {

    @Override
    public MessagePurger.PurgeMessageResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            // Establish connection with MariaDB
            MessagePurger purger = makeMessagePurger();
            MessagePurger.PurgeMessageResponse response = purger.purge(inputMap, context);
            if (response == null) {
                System.out.println("PurgeMessages: MessagePurger returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("PurgeMessages: MessagePurger returned valid response");
            return response;
        } catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("PurgeMessages: Could not close the database connection");
            return null;
        }
    }

    public MessagePurger makeMessagePurger() {
        System.out.println("PurgeMessages: Instantiating MessagePurger");
        return new MessagePurger(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("PurgeMessages: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
