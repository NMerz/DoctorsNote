package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.Map;

/*
 * A Lambda handler for removing events for a user.
 *
 * Expects: A JSON body with the following fields: eventId (int)
 * Returns: An empty object
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */

public class RemoveEvent implements RequestHandler<Map<String,Object>, EventRemover.RemoveEventResponse> {

    @Override
    public EventRemover.RemoveEventResponse handleRequest(Map<String,Object> inputMap, Context context) {
        // Establish connection with MariaDB
        EventRemover remover = makeEventRemover();
        EventRemover.RemoveEventResponse response = remover.remove(inputMap, context);
        if (response == null) {
            System.out.println("RemoveEvent: EventRemover returned null");
            throw new RuntimeException("Server experienced an error");
        }
        System.out.println("RemoveEvent: EventRemover returned valid response");
        return response;
    }

    public EventRemover makeEventRemover() {
        System.out.println("RemoveEvent: Instantiating EventRemover");
        return new EventRemover(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("RemoveEvent: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
