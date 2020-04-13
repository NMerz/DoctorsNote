package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for getting the two encryptions of the private  for a user.
 *
 * Expects: Any valid input map; a context validated by Cognito
 * Returns: A response object containing encryption1 (String), encryption2 (String)
 *
 * Error Handling: Rethrows any lower level error for log printing and return code setting
 */

public class GetKeys implements RequestHandler<Map<String,Object>, KeyGetter.GetKeysResponse> {
    @Override
    public KeyGetter.GetKeysResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            KeyGetter keyGetter = makeKeyGetter();
            KeyGetter.GetKeysResponse response = keyGetter.get(inputMap, context);
            if (response == null) {
                System.out.println("GetKeys: KeyGetter returned null");
                return null;
            } else {
                System.out.println("GetKeys: KeyGetter returned valid response");
                return response;
            }
        } catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("GetKeys: (Presumably) Could not close the database connection");
            return null;
        } catch (KeyGetter.GetKeysException e) {
            System.out.println("GetKeys: KeyGetter returned the error: " + e.getMessage());
            throw new RuntimeException("Server experienced an error: " + e.getMessage());
        }
    }

    public KeyGetter makeKeyGetter() {
        System.out.println("GetKeys: Instantiating EventGetter");
        return new KeyGetter(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("GetKeys: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}