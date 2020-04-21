package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for removing messages for a user.
 *
 * Expects: A JSON body with the following fields: messageId (int)
 * Returns: An empty object
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */

public class RemoveMessage implements RequestHandler<Map<String,Object>, MessageRemover.RemoveMessageResponse> {

    @Override
    public MessageRemover.RemoveMessageResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            // Establish connection with MariaDB
            MessageRemover remover = makeMessageRemover();
            MessageRemover.RemoveMessageResponse response = remover.remove(inputMap, context);
            if (response == null) {
                System.out.println("RemoveMessage: MessageRemover returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("RemoveMessage: MessageRemover returned valid response");
            return response;
        } catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("RemoveMessage: Could not close the database connection");
            return null;
        }
    }

    public MessageRemover makeMessageRemover() {
        System.out.println("RemoveMessage: Instantiating MessageRemover");
        return new MessageRemover(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("RemoveMessage: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
