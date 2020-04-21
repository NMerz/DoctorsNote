package DoctorsNote;

import com.amazonaws.services.cognitoidp.model.UserNotFoundException;
import com.amazonaws.services.lambda.runtime.Context;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class ListConversations {
    private final String getConversationFormatString = "SELECT conversationID FROM Conversation_has_User WHERE userID = ? ;";
    private final String getUserFormatString = "SELECT userID FROM Conversation_has_User WHERE conversationID = ? ;";
    private final String getNameTimeAndStatusFormatString = "SELECT conversationName, lastMessageTime, status, description " +
            "FROM Conversation WHERE conversationID = ?;";
    Connection dbConnection;

    public ListConversations(Connection dbConnection) { this.dbConnection = dbConnection; }

    private void printMap(Map<String, Object> map) {
        Gson gson = new Gson();
        Type gsonType = new TypeToken<Map>(){}.getType();
        String gsonString = gson.toJson(map,gsonType);
        System.out.println("ListConversations: Input Map: " + gsonString);
    }

    public ConversationListResponse list(Map<String,Object> inputMap, Context context) throws SQLException {
        try {
            String userId = (String)((Map<String,Object>) inputMap.get("context")).get("sub");
            printMap(inputMap);

            System.out.println("ListConversations: Getting conversations for " + userId);

            // Request necessary information from MariaDB and process into Conversation objects
            PreparedStatement getConversationStatement = dbConnection.prepareStatement(getConversationFormatString);
            getConversationStatement.setString(1, userId);
            System.out.println("ListConversations: getConversationStatement: " + getConversationStatement.toString());
            ResultSet conversationRS = getConversationStatement.executeQuery();

            ArrayList<String> conversationIds = new ArrayList<>();
            while (conversationRS.next()) { // Must finish reading all results of one query before executing another over the same connection
                conversationIds.add(conversationRS.getString(1));
            }

            ArrayList<Conversation> conversations = new ArrayList<>();
            for (String conversationId : conversationIds) {
                PreparedStatement getUserStatement = dbConnection.prepareStatement(getUserFormatString);
                getUserStatement.setString(1, conversationId);
                System.out.println("ListConversations: getUserStatement: " + getUserStatement.toString());
                ResultSet userRS = getUserStatement.executeQuery();

                ArrayList<String> converserIds = new ArrayList<>();
                String converserId;

                while (userRS.next()) {
                    converserId = userRS.getString(1);
                    if (!converserId.equals(userId)) {
                        System.out.println("ListConversations: Adding converserId: " + converserId);
                        converserIds.add(converserId);
                    }
                }

                System.out.println("ListConversations: converserIds: " + converserIds.toString());

                if (converserIds.size() == 0) {
                    continue;
                }

                PreparedStatement getDataStatement = dbConnection.prepareStatement(getNameTimeAndStatusFormatString);
                getDataStatement.setString(1, conversationId);
                System.out.println("ListConversations: getDataStatement: " + getDataStatement.toString());
                ResultSet nameAndTimeRS = getDataStatement.executeQuery();
                nameAndTimeRS.next();
                String conversationName = nameAndTimeRS.getString(1);
                //long lastMessageTime = nameAndTimeRS.getTimestamp(2).toInstant().getEpochSecond();
                long lastMessageTime = nameAndTimeRS.getTimestamp(2).toInstant().toEpochMilli();
                int status = nameAndTimeRS.getInt(3);
                String description = nameAndTimeRS.getString(4);
                String converserName;
                int numMembers;
                System.out.println("ListConversations: converserIds: " + converserIds.toString());

                // For difference between one to one convos and support groups
                if (converserIds.size() == 1) {
                    UserInfoGetter getter = new UserInfoGetter();

                    try {
                        UserInfoGetter.UserInfoResponse response = getter.get(getUserInfoMap(converserIds.get(0), userId), context);
                        converserName = String.format("%s %s", response.getFirstName(), response.getLastName());
                    } catch (NullPointerException e) {
                        converserName = converserIds.get(0);
                    }
                } else {
                    converserName = "N/A";
                }

                numMembers = converserIds.size() + 1;       // Since the requesting user isn't included in the size

                System.out.println("ListConversations: converserName: " + converserName);

                conversations.add(new Conversation(conversationName, conversationId, converserName, status, lastMessageTime, numMembers, description));
            }

            // Sort Conversation objects (-1 is to reverse the order to have newest times first)
            conversations.sort((o1, o2) -> -1 * Long.compare(o1.getLastMessageTime(), o2.getLastMessageTime()));

            // Combine Conversations into a ConversationListResponse  (tempArray resolves casting issue)
            Conversation[] tempArray = new Conversation[conversations.size()];
            System.out.println(String.format("ListConversations: Returning %d conversations for %s", conversations.size(), userId));

            ConversationListResponse conversationListResponse = new ConversationListResponse(conversations.toArray(tempArray));
            return conversationListResponse;
        } catch (Exception e) {
            System.out.println("ListConversations: Exception encountered: " + e.toString());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    private HashMap getUserInfoMap(String uid, String sub) {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("uid", uid);
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", sub);
        topMap.put("context", context);
        return topMap;
    }

    public class ConversationListRequest {
        private String userId;

        public ConversationListRequest() {
            this(null);
        }

        public ConversationListRequest(String userId) {
            this.userId = userId;
        }

        public String getUserId() {
            return userId;
        }

        public void setUserId(String userId) {
            this.userId = userId;
        }
    }

    public class Conversation {
        private String conversationName;
        private int conversationID;
        private String converserID;
        private int status;
        private long lastMessageTime;        // In UNIX time stamp. Should be long; int expires in 2038
        private int numMembers;
        private String description;

        public Conversation(String conversationName, String conversationID, String converserID, int status, long lastMessageTime, int numMembers, String description) {
            this.conversationName = conversationName;
            this.conversationID = Integer.parseInt(conversationID);
            this.converserID = converserID;
            this.status = status;
            this.lastMessageTime = lastMessageTime;
            this.numMembers = numMembers;
            this.description = description;
        }

        public String getConversationName() {
            return conversationName;
        }

        public void setConversationName(String conversationName) {
            this.conversationName = conversationName;
        }

        public int getConversationID() {
            return conversationID;
        }

        public void setConversationID(int conversationID) {
            this.conversationID = conversationID;
        }

        public void setConversationID(String conversationID) {
            this.conversationID = Integer.parseInt(conversationID);
        }

        public String getConverserID() {
            return converserID;
        }

        public void setConverserID(String converserIds) {
            this.converserID = converserIds;
        }

        public int getStatus() {
            return status;
        }

        public void setStatus(int status) {
            this.status = status;
        }

        public long getLastMessageTime() {
            return lastMessageTime;
        }

        public void setLastMessageTime(long lastMessageTime) {
            this.lastMessageTime = lastMessageTime;
        }

        public int getNumMembers() {
            return numMembers;
        }

        public void setNumMembers(int numMembers) {
            this.numMembers = numMembers;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }
    }

    public class ConversationListResponse {
        private Conversation[] conversationList;

        public ConversationListResponse(Conversation[] conversationList) {
            this.conversationList = conversationList;
        }

        public Conversation[] getConversationList() {
            return conversationList;
        }

        public void setConversationList(Conversation[] conversationList) {
            this.conversationList = conversationList;
        }
    }
}
