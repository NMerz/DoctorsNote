package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Map;

public class MessageGetter {
    private final String getMessagesFormatString = "SELECT content, messageID, timeCreated, sender FROM Message" +
            " WHERE conversationID = ? ORDER BY timeCreated DESC LIMIT ?;";
    Connection dbConnection;

    public MessageGetter(Connection dbConnection) { this.dbConnection = dbConnection; }

    public GetMessagesResponse get(Map<String,Object> inputMap, Context context) {
        try {
            // Reading from database
            PreparedStatement statement = dbConnection.prepareStatement(getMessagesFormatString);
            statement.setString(1, (String)((Map<String,Object>) inputMap.get("body-json")).get("conversationID"));
            statement.setString(2, (String)((Map<String,Object>) inputMap.get("body-json")).get("numberToRetrieve"));
            System.out.println("MessageGetter: statement: " + statement.toString());
            ResultSet messageResult = statement.executeQuery();

            messageResult.getFetchSize();

            // Processing results
            ArrayList<Message> messages = new ArrayList<>();
            while (messageResult.next()) {
                String content = messageResult.getString(1);
                String messageId = messageResult.getString(2);
                long timeSent = messageResult.getTimestamp(3).toInstant().getEpochSecond();
                String sender = messageResult.getString(4);

                if (timeSent >= 0) {
                    messages.add(new Message(content, messageId, timeSent, sender));
                }
            }

            // Disconnect connection with shortest lifespan possible
            dbConnection.close();

            System.out.println(String.format("MessageGetter: Returning %d messages for conversationID %s",
                    messages.size(),
                    ((Map<String,Object>) inputMap.get("body-json")).get("conversationID")));
            Message[] tempArray = new Message[messages.size()];
            GetMessagesResponse response = new GetMessagesResponse(messages.toArray(tempArray));

            return response;
        } catch (Exception e) {
            System.out.println("MessageGetter: Exception encountered: " + e.toString());
            return null;
        }
    }

    private class GetMessagesRequest {
        private String conversationId;
        private int nMessages;
        private int startIndex;
        private long sinceWhen;

        public String getConversationId() {
            return conversationId;
        }

        public void setConversationId(String conversationId) {
            this.conversationId = conversationId;
        }

        public int getnMessages() {
            return nMessages;
        }

        public void setnMessages(int nMessages) {
            this.nMessages = nMessages;
        }

        public int getStartIndex() {
            return startIndex;
        }

        public void setStartIndex(int startIndex) {
            this.startIndex = startIndex;
        }

        public long getSinceWhen() {
            return sinceWhen;
        }

        public void setSinceWhen(long sinceWhen) {
            this.sinceWhen = sinceWhen;
        }
    }

    private class Message {
        private String content;
        private String messageID;
        private long timeSent;
        private String sender;

        public Message(String content, String messageId, long timeSent, String sender) {
            this.content = content;
            this.messageID = messageId;
            this.timeSent = timeSent;
            this.sender = sender;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public String getMessageId() {
            return messageID;
        }

        public void setMessageId(String messageId) {
            this.messageID = messageId;
        }

        public long getTimeSent() {
            return timeSent;
        }

        public void setTimeSent(long timeSent) {
            this.timeSent = timeSent;
        }

        public String getSender() {
            return sender;
        }

        public void setSender(String sender) {
            this.sender = sender;
        }
    }

    public class GetMessagesResponse {
        private Message[] messageList;

        public GetMessagesResponse(Message[] messageList) {
            this.messageList = messageList;
        }

        public Message[] getMessages() {
            return messageList;
        }

        public void setMessages(Message[] messageList) {
            this.messageList = messageList;
        }
    }
}
