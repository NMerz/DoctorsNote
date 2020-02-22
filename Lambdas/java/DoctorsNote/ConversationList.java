package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import com.google.gson.Gson;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConversationList implements RequestHandler<String, String> {
    private final String DB_URL = "jdbc:mysql://doctorsnotedatabase.clqjrzlnojkj.us-east-2.rds.amazonaws.com:3306/";


    @Override
    public String handleRequest(String jsonString, Context context) {

        // Converting the passed JSON string into a POJO
        Gson gson = new Gson();
        ConversationListRequest request = gson.fromJson(jsonString, ConversationListRequest.class);

        // Establish connection with MariaDB
        DBCredentialsProvider dbCP;
        Connection connection = getConnection();
        if (connection == null) return gson.toJson(new ConversationListResponse(new Conversation[]{}));





        // TODO: Pipe return into instances of Conversation
        // TODO: Combine Conversations into a ConversationListResponse
        // TODO: Sort Conversation objects
        // TODO: Serialize and return ConversationListResponse

        return null;
    }

    private Connection getConnection() {
        try {
            DBCredentialsProvider dbCP = new DBCredentialsProvider();
            return DriverManager.getConnection(dbCP.getDBURL() + dbCP.getDBName(),
                    dbCP.getDBUsername(),
                    dbCP.getDBPassword());
        } catch (IOException | SQLException e) {
            return null;
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
        private String converserId;
        private String converserName;
        private int lastMessageTime;        // In UNIX time stamp

        public Conversation() {
            this(null, null, -1);
        }

        public Conversation(String converserId, String converserName, int lastMessageTime) {
            this.converserId = converserId;
            this.converserName = converserName;
            this.lastMessageTime = lastMessageTime;
        }

        public String getConverserId() {
            return converserId;
        }

        public void setConverserId(String converserId) {
            this.converserId = converserId;
        }

        public String getConverserName() {
            return converserName;
        }

        public void setConverserName(String converserName) {
            this.converserName = converserName;
        }

        public int getLastMessageTime() {
            return lastMessageTime;
        }

        public void setLastMessageTime(int lastMessageTime) {
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
}
