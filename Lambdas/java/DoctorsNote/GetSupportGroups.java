package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for getting the available support groups for a user.
 *
 * Expects: A valid context and any input map.
 * Returns: A JSON string containing an array of conversation ids.
 *
 * Error Handling: Returns null or a RuntimeException if an unrecoverable error is encountered
 */
public class GetSupportGroups implements RequestHandler<Map<String,Object>, SupportGroupGetter.GetSupportGroupsResponse> {

    public SupportGroupGetter.GetSupportGroupsResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            SupportGroupGetter supportGroupGetter = makeSupportGroupGetter();
            SupportGroupGetter.GetSupportGroupsResponse response = supportGroupGetter.get(inputMap, context);
            if (response == null) {
                System.out.println("GetSupportGroups: SupportGroupGetter returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("GetSupportGroups: SupportGroupGetter returned valid response");
            return response;
        } catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("GetSupportGroups: Could not close the database connection");
            return null;
        }
    }

    public SupportGroupGetter makeSupportGroupGetter() {
        System.out.println("GetSupportGroups: Instantiating SupportGroupGetter");
        return new SupportGroupGetter(Connector.getConnection());
    }

    public static void main(String[] args) {
        System.out.println("GetSupportGroups: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
