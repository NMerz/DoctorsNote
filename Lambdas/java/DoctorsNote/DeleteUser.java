package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.Map;

/*
 * A Lambda handler for deleting a user.
 *
 * Expects: An input map containing a user id (uid)
 * Returns: An empty response object
 *
 * Error Handling: Throws a RuntimeException if an unrecoverable error is encountered
 */

public class DeleteUser implements RequestHandler<Map<String,Object>, UserDeleter.DeleteUserResponse> {
    @Override
    public UserDeleter.DeleteUserResponse handleRequest(Map<String,Object> inputMap, Context context) {
        UserDeleter deleter = makeUserDeleter();
        UserDeleter.DeleteUserResponse response = deleter.delete(inputMap, context);
        if (response == null) {
            System.out.println("DeleteUser: UserDeleter returned null");
            throw new RuntimeException("Server experienced an error");
        }
        System.out.println("DeleteUser: UserDeleter returned valid response");
        return response;
    }

    public UserDeleter makeUserDeleter() {
        System.out.println("DeleteUser: Instantiating UserDeleter");
        return new UserDeleter();
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("DeleteUser: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
