package DoctorsNote;

/*
 * Logic to delete a user from AWS Cognito.
 */

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProvider;
import com.amazonaws.services.cognitoidp.model.AdminDeleteUserRequest;
import com.amazonaws.services.cognitoidp.model.AdminDeleteUserResult;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProviderClientBuilder;

import java.util.Map;

public class UserDeleter {
    public DeleteUserResponse delete(Map<String, Object> inputMap, Context context) {
        try {
            String username = (String)((Map<String,Object>) inputMap.get("body-json")).get("uid");
            System.out.println("UserDeleter: Deleting user " + username);

            System.out.println("UserDeleter: Obtaining AWS credentials and connection");
            BasicAWSCredentials credentials = new BasicAWSCredentials("AKIAVJGAVBLHELAXKTHY", "ZiTl/2QWgpzjeY71s7WDHA5ADzp6xvDRusZfyrK/");
            AWSCognitoIdentityProvider client = AWSCognitoIdentityProviderClientBuilder.standard()
                    .withCredentials(new AWSStaticCredentialsProvider(credentials)).withRegion(Regions.US_EAST_2).build();

            AdminDeleteUserRequest adminDeleteUserRequest = new AdminDeleteUserRequest()
                    .withUserPoolId("us-east-2_Cobrg1kBn")
                    .withUsername(username);
            System.out.println("UserDeleter: Requesting user deletion");
            AdminDeleteUserResult adminDeleteUserResult = client.adminDeleteUser(adminDeleteUserRequest);

            System.out.println("UserDeleter: User deleted successfully: " + username);
            return new DeleteUserResponse();
        } catch (Exception e) {
            System.out.println("UserDeleter: Exception encountered: " + e.getMessage());
            return null;
        }
    }

    public class DeleteUserResponse {}
}
