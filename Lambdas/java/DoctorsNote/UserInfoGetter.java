package DoctorsNote;

/*
 * Logic to process getting user info from AWS Cognito.
 */

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.cognitoidp.AWSCognitoIdentityProvider;
import com.amazonaws.services.cognitoidp.model.AdminGetUserRequest;
import com.amazonaws.services.cognitoidp.model.AdminGetUserResult;
import com.amazonaws.services.cognitoidp.model.AttributeType;
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

            HashMap<String, String> resultMap = new HashMap<>();
            for (AttributeType a : adminGetUserResult.getUserAttributes()) {
                resultMap.put(a.getName(), a.getValue());
            }

            UserInfoResponse response = new UserInfoResponse();
            response.setAddress(resultMap.get("address"));
            response.setEmail(resultMap.get("email"));
            response.setPhoneNumber(resultMap.get("phone_number"));
            response.setFirstName(resultMap.get("name"));
            response.setMiddleName(resultMap.get("middle_name").equals("<empty>") ? "" : resultMap.get("middle_name"));
            response.setLastName(resultMap.get("family_name"));

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
}
