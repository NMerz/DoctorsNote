package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for adding messages to a conversation on behalf of a user.
 *
 * The conversation must exist already or an exception will be encountered.
 *
 * Expects: A JSON string that maps to a POJO of type AddMessageRequest.
 * Returns: A JSON string that maps from a POJO of type AddMessageResponse.
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */
public class AddMessage implements RequestHandler<Map<String,Object>, MessageAdder.AddMessageResponse> {

    @Override
    public MessageAdder.AddMessageResponse handleRequest(Map<String,Object> inputMap, Context context) {

        try {
            MessageAdder messageAdder = makeMessageAdder();
            MessageAdder.AddMessageResponse response = messageAdder.add(inputMap, context);
            if (response == null) {
                System.out.println("AddMessage: MessageAdder returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("AddMessage: MessageAdder returned valid response");
            return response;
        }  catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("AddMessage: Could not close the database connection");
            return null;
        }
    }

    public MessageAdder makeMessageAdder() {
        System.out.println("AddMessage: Instantiating MessageAdder");
        return new MessageAdder(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("AddMessage: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
