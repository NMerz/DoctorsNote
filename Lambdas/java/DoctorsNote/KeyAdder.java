package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;


public class KeyAdder {
    private final String addKeysFormatString = "REPLACE INTO UserKeys(userID, encryptedKey1, encryptedKey2, publicKey) VALUES(?, ?, ?, ?);";
    Connection dbConnection;

    public KeyAdder(Connection dbConnection) { this.dbConnection = dbConnection; }

    public AddKeysResponse get(Map<String,Object> inputMap, Context context) throws SQLException, AddKeysException {
        try {
            String userID = ((Map<String,Object>)  inputMap.get("context")).get("sub").toString();
            System.out.println("Adding keys for UserID:" + userID);
            // Reading from database
            PreparedStatement statement = dbConnection.prepareStatement(addKeysFormatString);
            statement.setString(1, userID);
            statement.setString(2, ((Map<String,Object>)  inputMap.get("body-json")).get("privateKeyP").toString());
            statement.setString(3, ((Map<String,Object>)  inputMap.get("body-json")).get("privateKeyS").toString());
            statement.setString(4, ((Map<String,Object>)  inputMap.get("body-json")).get("publicKey").toString());

            System.out.println("KeyAdder: statement: " + statement.toString());

            int ret = statement.executeUpdate();

            if (ret == 1) {
                System.out.println("KeyAdder: Insert successful");
            } else if (ret == 2) {
                System.out.println("KeyAdder: Update successful");
            } else {
                System.out.println(String.format("KeyAdder: Update failed (%d)", ret));
            }

            return null;
        } catch (Exception e) {
            System.out.println("KeyAdder: Exception encountered: " + e.toString());
            throw new AddKeysException(e.getMessage());
        } finally {
            dbConnection.close();
        }
    }


    public class AddKeysResponse {

    }

    public class AddKeysException extends Exception {
        String message;
        AddKeysException(String message) {
            this.message = message;
        }

        @Override
        public String getMessage() {
            return message;
        }
    }
}