package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for adding events for a user.
 *
 * Expects: A JSON body with the following fields: startTime (epoch time), endTime (epoch time), location (String), title (String), description (String), userID (String)
 * Returns: An empty object
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */

public class AddEvent implements RequestHandler<Map<String,Object>, EventAdder.AddEventResponse> {

    @Override
    public EventAdder.AddEventResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            // Establish connection with MariaDB
            EventAdder adder = makeEventAdder();
            EventAdder.AddEventResponse response = adder.add(inputMap, context);
            if (response == null) {
                System.out.println("AddEvent: EventAdder returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("AddEvent: EventAdder returned valid response");
            return response;
        } catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("AddEvent: Could not close the database connection");
            return null;
        }
    }

    public EventAdder makeEventAdder() {
        System.out.println("AddEvent: Instantiating EventAdder");
        return new EventAdder(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("AddEvent: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
