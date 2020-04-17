package DoctorsNote;

/*
 * Logic to process getting user info from AWS Cognito.
 * NOTE: The passed connection will be closed
 */

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProvider;
import com.amazonaws.services.cognitoidp.model.AdminGetUserRequest;
import com.amazonaws.services.cognitoidp.model.AdminGetUserResult;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProviderClientBuilder;

import java.util.HashMap;
import java.util.Map;

public class UserInfoGetter {

    @SuppressWarnings("unckecked")
    public UserInfoResponse get(Map<String, Object> inputMap, Context context) {
        try {
            String username = (String)((Map<String,Object>) inputMap.get("body-json")).get("uid");
            System.out.println("UserInfoGetter: Getting user info for " + username);

            System.out.println("UserInfoGetter: Obtaining AWS credentials and connection");
            BasicAWSCredentials credentials = new BasicAWSCredentials("AKIAVJGAVBLHELAXKTHY", "ZiTl/2QWgpzjeY71s7WDHA5ADzp6xvDRusZfyrK/");
            AWSCognitoIdentityProvider client = AWSCognitoIdentityProviderClientBuilder.standard()
                    .withCredentials(new AWSStaticCredentialsProvider(credentials)).withRegion(Regions.US_EAST_2).build();

            AdminGetUserRequest adminGetUserRequest = new AdminGetUserRequest()
                    .withUserPoolId("us-east-2_Cobrg1kBn")
                    .withUsername(username);
            System.out.println("UserInfoGetter: Requesting user information");
            AdminGetUserResult adminGetUserResult = client.adminGetUser(adminGetUserRequest);
            System.out.println("UserInfoGetter: User information received");

            // To get indices, run in debugging mode and look at the list itself;
            // indices are consistent until changes are made to Cognito
            UserInfoResponse response = new UserInfoResponse();
            response.setAddress(adminGetUserResult.getUserAttributes().get(1).getValue());
            response.setEmail(adminGetUserResult.getUserAttributes().get(10).getValue());
            response.setFirstName(adminGetUserResult.getUserAttributes().get(7).getValue());
            response.setMiddleName(adminGetUserResult.getUserAttributes().get(6).getValue());
            response.setLastName(adminGetUserResult.getUserAttributes().get(9).getValue());
            response.setPhoneNumber(adminGetUserResult.getUserAttributes().get(8).getValue());

            System.out.println("UserInfoGetter: Info retrieved correctly; returning valid response");
            return response;
        } catch (Exception e) {
            System.out.println("UserInfoGetter: Exception encountered: " + e.getMessage());
            return null;
        }
    }

    public class UserInfoResponse {
        private String email;
        private String firstName;
        private String middleName;
        private String lastName;
        private String address;
        private String phoneNumber;

        public UserInfoResponse(String email, String firstName, String middleName, String lastName, String address, String phoneNumber) {
            this.email = email;
            this.firstName = firstName;
            this.middleName = middleName;
            this.lastName = lastName;
            this.address = address;
            this.phoneNumber = phoneNumber;
        }

        public UserInfoResponse() {
            this("", "", "", "", "", "");
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getFirstName() {
            return firstName;
        }

        public void setFirstName(String firstName) {
            this.firstName = firstName;
        }

        public String getMiddleName() {
            return middleName;
        }

        public void setMiddleName(String middleName) {
            this.middleName = middleName;
        }

        public String getLastName() {
            return lastName;
        }

        public void setLastName(String lastName) {
            this.lastName = lastName;
        }

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public String getPhoneNumber() {
            return phoneNumber;
        }

        public void setPhoneNumber(String phoneNumber) {
            this.phoneNumber = phoneNumber;
        }
    }

    public static void main(String[] args) {
        HashMap<String, Object> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("uid", "6f290288-afe5-4912-b200-204709232288");
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "0000000001"); //Note: not an accurate length for sample id
        topMap.put("context", context);

        UserInfoGetter getter = new UserInfoGetter();
        getter.get(topMap, null);
    }
}
