package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.Map;

/*
 * A Lambda handler for getting information for a user.
 *
 * Expects: An input map containing a user id
 * Returns: Relevant fields from Cognito for that user
 *
 * Error Handling: Throws a RuntimeException if an unrecoverable error is encountered
 */

public class GetUserInfo implements RequestHandler<Map<String,Object>, UserInfoGetter.UserInfoResponse> {
    @Override
    public UserInfoGetter.UserInfoResponse handleRequest(Map<String,Object> inputMap, Context context) {
        // Establish connection with MariaDB
        UserInfoGetter getter = makeUserInfoGetter();
        UserInfoGetter.UserInfoResponse response = getter.get(inputMap, context);
        if (response == null) {
            System.out.println("GetUserInfo: UserInfoGetter returned null");
            throw new RuntimeException("Server experienced an error");
        }
        System.out.println("GetUserInfo: UserInfoGetter returned valid response");
        return response;
    }

    public UserInfoGetter makeUserInfoGetter() {
        System.out.println("GetUserInfo: Instantiating UserInfoGetter");
        return new UserInfoGetter();
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("GetUserInfo: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
