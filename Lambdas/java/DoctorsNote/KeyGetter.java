package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

public class KeyGetter {
    private final String getMessagesFormatString = "SELECT encryptedKey1, encryptedKey2 FROM UserKeys" +
            " WHERE userID = ?;";
    Connection dbConnection;

    public KeyGetter(Connection dbConnection) { this.dbConnection = dbConnection; }

    public GetKeysResponse get(Map<String,Object> inputMap, Context context) throws SQLException, GetKeysException {
        try {
            String userID = (String)((Map<String,Object>)  inputMap.get("context")).get("sub");
            // Reading from database
            PreparedStatement statement = dbConnection.prepareStatement(getMessagesFormatString);
            statement.setString(1, userID);
            System.out.println("KeyGetter: statement: " + statement.toString());

            ResultSet keyResult = statement.executeQuery();

            if (keyResult.getFetchSize() > 1) {
                throw new GetKeysException("Error: more than one row of key entries found!");
            }

            // Processing results
            if (keyResult.next()) {
                String privateKeyP = keyResult.getString(1);
                String privateKeyS = keyResult.getString(2);
                return new GetKeysResponse(privateKeyP, privateKeyS);
            }
            return null;
        } catch (Exception e) {
            System.out.println("MessageGetter: Exception encountered: " + e.toString());
            throw new GetKeysException(e.getMessage());
        } finally {
            dbConnection.close();
        }
    }


    public class GetKeysResponse {
        private String privateKeyP;
        private String privateKeyS;

        public GetKeysResponse(String privateKeyP, String privateKeyS) {
            this.privateKeyP = privateKeyP;
            this.privateKeyS = privateKeyS;
        }

        public String getPrivateKeyP() {
            return privateKeyP;
        }

        public String getPrivateKeyS() {
            return privateKeyS;
        }

        public void setPrivateKeyP(String privateKeyP) {
            this.privateKeyP = privateKeyP;
        }

        public void setPrivateKeyS(String privateKeyS) {
            this.privateKeyS = privateKeyS;
        }
    }

    public class GetKeysException extends Exception {
        String message;
        GetKeysException(String message) {
            this.message = message;
        }

        @Override
        public String getMessage() {
            return message;
        }
    }
}