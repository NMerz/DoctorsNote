package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for getting events for a user.
 *
 * Expects: Any valid input map; a context validated by Cognito
 * Returns: A response object containing eventId (String), startTime (long), endTime (long), location (String),
 *          title (String), description (String), userId (String)
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */

public class GetEvents implements RequestHandler<Map<String,Object>, EventGetter.GetEventsResponse> {
    @Override
    public EventGetter.GetEventsResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            // Establish connection with MariaDB
            EventGetter getter = makeEventGetter();
            EventGetter.GetEventsResponse response = getter.get(inputMap, context);
            if (response == null) {
                System.out.println("GetEvents: EventGetter returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("GetEvents: EventGetter returned valid response");
            return response;
        }  catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("GetEvents: Could not close the database connection");
            return null;
        }
    }

    public EventGetter makeEventGetter() {
        System.out.println("GetEvents: Instantiating EventGetter");
        return new EventGetter(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("GetEvents: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
