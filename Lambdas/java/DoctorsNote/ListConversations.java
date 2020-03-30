package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Map;

public class ListConversations {
    private final String getConversationFormatString = "SELECT conversationID FROM Conversation_has_User WHERE userID = ? ;";
    private final String getUserFormatString = "SELECT userID FROM Conversation_has_User WHERE conversationID = ? ;";
    private final String getNameTimeAndStatusFormatString = "SELECT conversationName, lastMessageTime, status " +
            "FROM Conversation WHERE conversationID = ?;";
    Connection dbConnection;

    public ListConversations(Connection dbConnection) { this.dbConnection = dbConnection; }

    public ConversationListResponse list(Map<String,Object> jsonString, Context context) {
        try {
            System.out.println("ListConversations: Getting conversations for " + context.getIdentity().getIdentityId());
            ConversationListRequest request = new ConversationListRequest(context.getIdentity().getIdentityId());

            // Extracting necessary fields from POJO
            String userId = request.getUserId();

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
                ResultSet userRS = getConversationStatement.executeQuery();

                ArrayList<String> converserIds = new ArrayList<>();
                String converserId;

                while (userRS.next()) {
                    converserId = userRS.getString(1);
                    if (!converserId.equals(userId)) {
                        converserIds.add(converserId);
                    }
                }

                if (converserIds.size() == 0) {
                    continue;
                }

                PreparedStatement getDataStatement = dbConnection.prepareStatement(getNameTimeAndStatusFormatString);
                getDataStatement.setString(1, conversationId);
                System.out.println("ListConversations: getDataStatement: " + getDataStatement.toString());
                ResultSet nameAndTimeRS = getDataStatement.executeQuery();
                nameAndTimeRS.next();
                String conversationName = nameAndTimeRS.getString(1);
                long lastMessageTime = nameAndTimeRS.getTimestamp(2).toInstant().getEpochSecond();
                int status = nameAndTimeRS.getInt(3);
                String converserIdString;

                // For difference between one to one convos and support groups
                if (converserIds.size() == 1) {
                    converserIdString = converserIds.get(0);
                } else {
                    converserIdString = "N/A";
                }

                conversations.add(new Conversation(conversationName, conversationId, converserIdString, status, lastMessageTime));
            }

            // Disconnect connection with shortest lifespan possible
            dbConnection.close();

            // Sort Conversation objects (-1 is to reverse the order to have newest times first)
            conversations.sort((o1, o2) -> -1 * Long.compare(o1.getLastMessageTime(), o2.getLastMessageTime()));

            // Combine Conversations into a ConversationListResponse  (tempArray resolves casting issue)
            Conversation[] tempArray = new Conversation[conversations.size()];
            System.out.println(String.format("ListConversations: Returning %d conversations for %s", conversations.size(), userId));

            ConversationListResponse conversationListResponse = new ConversationListResponse(conversations.toArray(tempArray));
            return conversationListResponse;
        } catch (Exception e) {
            System.out.println("ListConversations: Exception encountered: " + e.getMessage());
            return null;
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
        private String converserID;
        private int status;
        private long lastMessageTime;        // In UNIX time stamp. Should be long; int expires in 2038

        public Conversation(String conversationName, String conversationID, String converserID, int status, long lastMessageTime) {
            this.conversationName = conversationName;
            this.conversationID = Integer.parseInt(conversationID);
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
