package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.Map;

/*
 * A Lambda handler for getting all conversations the requesting user is currently a part of.
 *
 * Expects: A JSON string that maps to a POJO of type ConversationListRequest
 * Returns: A JSON string that maps from a POJO of type ConversationListResponse
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */
public class ConversationList implements RequestHandler<Map<String,Object> , Object> {
    private final String getConversationFormatString = "SELECT conversationID FROM Conversation_has_User WHERE userID=%s;";
    private final String getUserFormatString = "SELECT userID FROM Conversation_has_User WHERE conversationID=%s;";
    private final String getNameTimeAndStatusFormatString = "SELECT conversationName, lastMessageTime, status " +
            "FROM Conversation WHERE conversationID=%s;";

    public ConversationListResponse handleRequest(Map<String,Object> jsonString, Context context) {
        try {
            ConversationListRequest request = new ConversationListRequest(((Map<String,Object>)jsonString.get("context")).get("user").toString());

            // Extracting necessary fields from POJO
            String userId = request.getUserId();

            // Establish connection with MariaDB
            Connection connection = getConnection();

            // Request necessary information from MariaDB and process into Conversation objects
            Statement statement = connection.createStatement();
            ResultSet conversationRS = statement.executeQuery(String.format(getConversationFormatString, userId));

            ArrayList<String> conversationIds = new ArrayList<>();
            while (conversationRS.next()) { //Must finish reading all results of one query before executing another over the same connection
                conversationIds.add(conversationRS.getString(1));
            }
            ArrayList<Conversation> conversations = new ArrayList<>();
            for (String conversationId : conversationIds) {
                ResultSet userRS = statement.executeQuery(String.format(getUserFormatString, conversationId));

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
                if (converserIds.size() > 1) {
                    throw (new NoSuchMethodException());
                }
                ResultSet nameAndTimeRS = statement.executeQuery(String.format(getNameTimeAndStatusFormatString, conversationId));
                nameAndTimeRS.next();
                String conversationName = nameAndTimeRS.getString(1);
                long lastMessageTime = nameAndTimeRS.getTimestamp(2).toInstant().getEpochSecond();
                int status = nameAndTimeRS.getInt(3);

                if (converserIds.size() == 0) {
                    continue;
                }
                String[] converserIdsArray = new String[converserIds.size()];
                converserIds.toArray(converserIdsArray);
                conversations.add(new Conversation(conversationName, conversationId, converserIdsArray, status, lastMessageTime));
            }

            // Disconnect connection with shortest lifespan possible
            connection.close();

            // Sort Conversation objects (-1 is to reverse the order to have newest times first)
            conversations.sort((o1, o2) -> -1 * Long.compare(o1.getLastMessageTime(), o2.getLastMessageTime()));

            // Combine Conversations into a ConversationListResponse  (tempArray resolves casting issue)
            Conversation[] tempArray = new Conversation[conversations.size()];

            return new ConversationListResponse(conversations.toArray(tempArray));
        } catch (Exception e) {
            System.out.println(e.toString());
            return null;
        }
    }

    private Connection getConnection() {
        try {
            DBCredentialsProvider dbCP = new DBCredentialsProvider();
            Class.forName(dbCP.getDBDriver());     // Loads and registers the driver
            return DriverManager.getConnection(dbCP.getDBURL(),
                    dbCP.getDBUsername(),
                    dbCP.getDBPassword());
        } catch (IOException | SQLException | ClassNotFoundException e) {
            throw new NullPointerException("Failed to load connection in ConversationList:getConnection()");
        }
    }

    private class ConversationListRequest {
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

    private class Conversation {
        private String conversationName;
        private int conversationID;
        private int converserID;
        private int status;
        private long lastMessageTime;        // In UNIX time stamp. Should be long; int expires in 2038

        public Conversation(String conversationName, String conversationID, String[] converserIds, int status, long lastMessageTime) {
            this.conversationName = conversationName;
            this.conversationID = Integer.parseInt(conversationID);
            //TODO: generalize this to multiple conversers if needed for Support Groups
            this.converserID = Integer.parseInt(converserIds[0]);
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

        public int getConverserID() {
            return converserID;
        }

        public void setConverserID(String[] converserIds) {
            this.converserID = Integer.parseInt(converserIds[0]);
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

    private class ConversationListResponse {
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

    public static void main(String[] args) throws IllegalStateException {
        throw new IllegalStateException();
    }
}
