package DoctorsNote;

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
import java.util.Map;

public class ListConversations {
    private final String getConversationFormatString = "SELECT conversationID FROM Conversation_has_User WHERE userID = ? ;";
    private final String getUserFormatString = "SELECT userID FROM Conversation_has_User WHERE conversationID = ? ;";
    private final String getConverserPublicKeyFormatString = "SELECT publicKey FROM UserKeys WHERE userID = ? ;";
    private final String getDetailsFormatString = "SELECT conversationName, lastMessageTime, status, adminPublicKey " +
            "FROM Conversation WHERE conversationID = ?;";
    Connection dbConnection;

    public ListConversations(Connection dbConnection) { this.dbConnection = dbConnection; }

    private void printMap(Map<String, Object> map) {
        Gson gson = new Gson();
        Type gsonType = new TypeToken<Map>(){}.getType();
        String gsonString = gson.toJson(map,gsonType);
        System.out.println("ListConversations: Input Map: " + gsonString);
    }

    public ConversationListResponse list(Map<String,Object> jsonString, Context context) throws SQLException {
        try {
            printMap(jsonString);
            String userId = (String)((Map<String,Object>)  jsonString.get("context")).get("sub");
            for (String key : ((Map<String,Object>)jsonString.get("context")).keySet()) {
                System.out.println("Key:" + key);
                System.out.println(((Map<String,Object>)jsonString.get("context")).get(key));
            }
//            ConversationListRequest request = new ConversationListRequest(jsonString.get("userId").toString());
            ConversationListRequest request = new ConversationListRequest(((Map<String,Object>)jsonString.get("context")).get("sub").toString());

            System.out.println("ListConversations: Getting conversations for " + ((Map<String,Object>)  jsonString.get("context")).get("sub").toString());

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

                System.out.println("ListConversations: converserIds at line 67: " + converserIds.toString());

                if (converserIds.size() == 0) {
                    continue;
                }

                PreparedStatement getDataStatement = dbConnection.prepareStatement(getDetailsFormatString);
                getDataStatement.setString(1, conversationId);
                System.out.println("ListConversations: getDataStatement: " + getDataStatement.toString());
                ResultSet attributesRS = getDataStatement.executeQuery();
                attributesRS.next();
                String conversationName = attributesRS.getString(1);
                //long lastMessageTime = nameAndTimeRS.getTimestamp(2).toInstant().getEpochSecond();
                long lastMessageTime = attributesRS.getTimestamp(2).toInstant().toEpochMilli();
                int status = attributesRS.getInt(3);
                String adminPublicKey = attributesRS.getString(4);
                String converserIdString;
                String converserPublicKey;
                System.out.println("ListConversations: converserIds: " + converserIds.toString());

                // For difference between one to one convos and support groups
                if (converserIds.size() == 1) {
                    converserIdString = converserIds.get(0);
                    PreparedStatement getPublicKeyStatement = dbConnection.prepareStatement(getConverserPublicKeyFormatString);
                    getPublicKeyStatement.setString(1, converserIdString);
                    ResultSet publicKeyRS = getPublicKeyStatement.executeQuery();
                    if (publicKeyRS.next()) {
                        converserPublicKey = publicKeyRS.getString(1);
                        if (publicKeyRS.next()) {
                            throw new ConversationListException("More than one public key available for converser " + converserIdString);
                        }
                    } else {
                        throw new ConversationListException("No public key available for converser " + converserIdString);
                    }
                } else {
                    converserIdString = "N/A";
                    converserPublicKey = "N/A";
                    adminPublicKey = "N/A";
                }

                System.out.println("ListConversations: converserIdString at line 93: " + converserIdString);

                conversations.add(new Conversation(conversationName, conversationId, converserPublicKey, adminPublicKey, converserIdString, status, lastMessageTime));
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
        private String converserPublicKey;
        private String adminPublicKey;
        private String converserID;
        private int status;
        private long lastMessageTime;        // In UNIX time stamp. Should be long; int expires in 2038

        public Conversation(String conversationName, String conversationID, String converserPublicKey, String adminPublicKey, String converserID, int status, long lastMessageTime) {
            this.conversationName = conversationName;
            this.conversationID = Integer.parseInt(conversationID);
            this.converserPublicKey = converserPublicKey;
            this.adminPublicKey = adminPublicKey;
            this.converserID = converserID;
            this.status = status;
            this.lastMessageTime = lastMessageTime;
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

        public String getConverserPublicKey() {
            return converserPublicKey;
        }

        public void setConverserPublicKey(String converserPublicKey) {
            this.converserPublicKey = converserPublicKey;
        }

        public String getAdminPublicKey() {
            return adminPublicKey;
        }

        public void setAdminPublicKey(String adminPublicKey) {
            this.adminPublicKey = adminPublicKey;
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

    public class ConversationListException extends Exception {
        String message;
        ConversationListException(String message) {
            this.message = message;
        }

        @Override
        public String getMessage() {
            return message;
        }
    }
}
