package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for adding the two encryptions of the private key and the corresponding public key for a user.
 *
 * Expects: Any valid input map; a context validated by Cognito
 * Returns: A response object containing encryption1 (String), encryption2 (String)
 *
 * Error Handling: Rethrows any lower level error for log printing and return code setting
 */



public class AddKeys implements RequestHandler<Map<String,Object>, KeyAdder.AddKeysResponse> {
    @Override
    public KeyAdder.AddKeysResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            KeyAdder keyadder = makeKeyAdder();
            KeyAdder.AddKeysResponse response = keyadder.get(inputMap, context);
            if (response == null) {
                System.out.println("AddKeys: KeyAdder returned null");
                return null;
            } else {
                System.out.println("AddKeys: KeyAdder returned valid response");
                return response;
            }
        } catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("AddKeys: (Presumably) Could not close the database connection");
            return null;
        } catch (KeyAdder.AddKeysException e) {
            System.out.println("AddKeys: KeyAdder returned the error: " + e.toString());
            throw new RuntimeException("Server experienced an error: " + e.getMessage());
        }
    }

    public KeyAdder makeKeyAdder() {
        System.out.println("AddKeys: Instantiating KeyAdder");
        return new KeyAdder(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("GetKeys: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}