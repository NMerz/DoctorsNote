package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import com.google.gson.Gson;

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

//            System.out.println(jsonString);
//            System.out.flush();
//            System.out.println(jsonString.get("userId"));
            //System.out.flush();
            //System.out.println(((Map<String,Object>) jsonString.get("headers")).get("Accept"));
            //System.out.flush();
            //System.out.println(jsonString.get("body"));
            //System.out.flush();
            //System.out.println(jsonString.get("body").getClass());
            //System.out.flush();
            //System.out.println(((Map<String,Object>) jsonString.get("body")).get("userId"));
            //System.out.flush();
            //String userID = (String) ((Map<String,Object>) jsonString.get("body")).get("userId");
            Gson gson = new Gson();
            //return gson.toJson(userID);

            // Converting the passed JSON string into a POJO
            //ConversationListRequest request = gson.fromJson(jsonString.get("body"), ConversationListRequest.class);

            //ConversationListRequest request = new ConversationListRequest((String) ((Map<String,Object>) jsonString.get("body")).get("userId"));
            //ConversationListRequest request = gson.fromJson(jsonString.get("body").toString(), ConversationListRequest.class);
            System.out.println(context.getIdentity().getIdentityPoolId());
            System.out.println(context.getIdentity().getIdentityId());
            for (String key : ((Map<String,Object>)jsonString.get("context")).keySet()) {
                System.out.println("Key:" + key);
                System.out.println(((Map<String,Object>)jsonString.get("context")).get(key));
            }
//            ConversationListRequest request = new ConversationListRequest(jsonString.get("userId").toString());
            ConversationListRequest request = new ConversationListRequest(((Map<String,Object>)jsonString.get("context")).get("user").toString());

            // Extracting necessary fields from POJO
            String userId = request.getUserId();
            System.out.println("userID: " + userId);
            // Establish connection with MariaDB
            DBCredentialsProvider dbCP;
            System.out.println("Pre connection");
            System.out.flush();
            Connection connection = getConnection();
            System.out.println("Connection:" + connection);
            System.out.flush();
            // Request necessary information from MariaDB and process into Conversation objects
            Statement statement = connection.createStatement();
            ResultSet conversationRS = statement.executeQuery(String.format(getConversationFormatString, userId));
            ArrayList<String> conversationIds = new ArrayList<>();
            while (conversationRS.next()) { //Must finish reading all results of one query before executing another over the same connection
                conversationIds.add(conversationRS.getString(1));
            }
            ArrayList<Conversation> conversations = new ArrayList<>();
            for (String conversationId : conversationIds) {
                System.out.println("conversationID:" + conversationId);
                System.out.flush();
                ResultSet userRS = statement.executeQuery(String.format(getUserFormatString, conversationId));

                ArrayList<String> converserIds = new ArrayList<>();
                String converserId;
                while (userRS.next()) {
                    converserId = userRS.getString(1);
                    System.out.println("converserID:" + converserId);
                    System.out.flush();
                    if (!converserId.equals(userId)) {
                        converserIds.add(converserId);
                    }
                }
                if (converserIds.size() == 0) {
                    System.out.println("continuing");
                    System.out.flush();
                    continue;
                }
                if (converserIds.size() > 1) {
                    throw (new NoSuchMethodException());
                }
                ResultSet nameAndTimeRS = statement.executeQuery(String.format(getNameTimeAndStatusFormatString, conversationId));
                nameAndTimeRS.next();
                String conversationName = nameAndTimeRS.getString(1);
                System.out.println("conversationName:" + conversationName);
                System.out.flush();
                long lastMessageTime = nameAndTimeRS.getTimestamp(2).toInstant().getEpochSecond();
                int status = nameAndTimeRS.getInt(3);
                System.out.println("status:" + status);
                System.out.flush();
//                System.out.println("converserIds:" + converserIds.toArray().getClass().toString());
//                System.out.println("converserIds size:" + converserIds.size());
//                String[] converserIdsArray = new String[converserIds.size()];
//                System.out.println("converserIds:" + converserIds.toArray(converserIdsArray));
//                System.out.flush();
//                System.out.println("converserIds:" + converserIds.toArray().toString());
//                System.out.flush();

                if (converserIds.size() == 0) {
                    continue;
                }
                System.out.println(conversationName);
                System.out.println(conversationId);
                String[] converserIdsArray = new String[converserIds.size()];
                converserIds.toArray(converserIdsArray);
                System.out.println(converserIdsArray);
                System.out.println(status);
                System.out.println(lastMessageTime);
                conversations.add(new Conversation(conversationName, conversationId, converserIdsArray, status, lastMessageTime));
                System.out.println("conversations:" + conversations);
                System.out.flush();
            }
            System.out.println("conversations done");
            System.out.flush();
            System.out.println("conversations:" + conversations);
            System.out.flush();
            // Disconnect connection with shortest lifespan possible
            connection.close();

            // Sort Conversation objects (-1 is to reverse the order to have newest times first)
            conversations.sort((o1, o2) -> -1 * Long.compare(o1.getLastMessageTime(), o2.getLastMessageTime()));

            // Combine Conversations into a ConversationListResponse  (tempArray resolves casting issue)
            Conversation[] tempArray = new Conversation[conversations.size()];
            ConversationListResponse conversationListResponse = new ConversationListResponse(conversations.toArray(tempArray));
            System.out.println("response:" + conversationListResponse);
            System.out.flush();
            // Serialize and return ConversationListResponse
            //String response = "{\"isBase64Encoded\":false,\"statusCode\": 200, \"headers\": {\"Content-Type\" : \"application/json\"},\"body\":" + gson.toJson(conversationListResponse) +"}";
            //System.out.println("Response: " + response);
            //System.out.flush();
            return conversationListResponse;
        } catch (Exception e) {
            return null;
        }
    }

    private int printMe(String toPrint) {
        System.out.println(toPrint);
        System.out.flush();
        return 1;
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
