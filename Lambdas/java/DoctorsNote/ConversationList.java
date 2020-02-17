package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import com.google.gson.Gson;

public class ConversationList implements RequestHandler<String, String> {
    @Override
    public String handleRequest(String jsonString, Context context) {
        Gson gson = new Gson();
        ConversationListRequest request = gson.fromJson(jsonString, ConversationListRequest.class);

        // TODO: Connect to MariaDB and retrieve correct information
        // TODO: Pipe return into instances of Conversation
        // TODO: Combine Conversations into a ConversationListResponse
        // TODO: Sort Conversation objects
        // TODO: Serialize and return ConversationListResponse

        return null;
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
        private int nConversations;

        public ConversationListResponse(Conversation[] conversationList) {
            this.conversationList = conversationList;
            this.nConversations = conversationList.length;
        }

        public Conversation[] getConversationList() {
            return conversationList;
        }

        public int getnConversations() {
            return nConversations;
        }

        public void setConversationList(Conversation[] conversationList) {
            this.conversationList = conversationList;
            this.nConversations = conversationList.length;
        }
    }
}
