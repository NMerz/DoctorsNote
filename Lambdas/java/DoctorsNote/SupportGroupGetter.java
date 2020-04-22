package DoctorsNote;

/*
 * Logic to process getting support groups a user is not yet a part of.
 * NOTE: The passed connection will be closed
 */

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Map;

public class SupportGroupGetter {
    private final String getGroupsFormatString = "SELECT conversationID FROM Conversation_has_User WHERE userID != ? GROUP BY conversationID HAVING COUNT(*) > 2;";
    Connection dbConnection;

    public SupportGroupGetter(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public GetSupportGroupsResponse get(Map<String, Object> inputMap, Context context) throws SQLException {
        try {
            String userId = (String)((Map<String,Object>) inputMap.get("context")).get("sub");

            PreparedStatement statement = dbConnection.prepareStatement(getGroupsFormatString);
            System.out.println("SupportGroupsGetter: Getting available groups for " + userId);
            statement.setString(1, userId);
            System.out.println("SupportGroupsGetter: statement: " + statement);
            ResultSet groupsRS = statement.executeQuery();

            // Processing results
            ArrayList<String> groups = new ArrayList<>();
            while (groupsRS.next()) {
                groups.add(groupsRS.getString(1));
            }

            System.out.println(String.format("SupportGroupsGetter: Returning %d groups for %s", groups.size(), userId));

            String[] tempArray = new String[groups.size()];
            return new GetSupportGroupsResponse(groups.toArray(tempArray));
        } catch (Exception e) {
            System.out.println("SupportGroupsGetter: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }


    public class GetSupportGroupsResponse {
        private String[] conversationIds;

        public GetSupportGroupsResponse(String[] conversationIds) {
            this.conversationIds = conversationIds;
        }

        public String[] getConversationIds() {
            return conversationIds;
        }

        public void setConversationIds(String[] conversationIds) {
            this.conversationIds = conversationIds;
        }
    }
}
