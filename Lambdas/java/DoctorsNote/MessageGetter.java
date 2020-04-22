package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Map;

public class MessageGetter {
    private final String getMessagesFormatString = "SELECT messageID, timeCreated, sender, contentType, senderContent, receiverContent FROM Message" +
            " WHERE conversationID = ? ORDER BY timeCreated DESC LIMIT ?;";
    Connection dbConnection;

    public MessageGetter(Connection dbConnection) { this.dbConnection = dbConnection; }

    public GetMessagesResponse get(Map<String,Object> inputMap, Context context) throws SQLException {
        try {
            String currentUser = ((Map<String,Object>) inputMap.get("context")).get("sub").toString();
            // Reading from database
            PreparedStatement statement = dbConnection.prepareStatement(getMessagesFormatString);
            statement.setLong(1, Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("conversationID").toString()));
            statement.setLong(2, Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("numberToRetrieve").toString()));
            System.out.println("MessageGetter: statement: " + statement.toString());

            ResultSet messageResult = statement.executeQuery();

            messageResult.getFetchSize();

            // Processing results
            ArrayList<Message> messages = new ArrayList<>();
            while (messageResult.next()) {
                long messageId = messageResult.getLong(1);
                long timeSent = messageResult.getTimestamp(2).toInstant().toEpochMilli();
                String sender = messageResult.getString(3);
                long contentType = messageResult.getLong(4);
                String senderContent = messageResult.getString(5);
                String receiverContent = messageResult.getString(6);

                if (timeSent >= 0) {
                    if (currentUser.equals(sender)) {
                        messages.add(new Message(senderContent, contentType, messageId, timeSent, sender));
                    } else {
                        messages.add(new Message(receiverContent, contentType, messageId, timeSent, sender));
                    }
                }
            }

            System.out.println(String.format("MessageGetter: Returning %d messages for conversationID %s",
                    messages.size(),
                    ((Map<String,Object>) inputMap.get("body-json")).get("conversationID")));
            Message[] tempArray = new Message[messages.size()];
            GetMessagesResponse response = new GetMessagesResponse(messages.toArray(tempArray));

            return response;
        } catch (Exception e) {
            System.out.println("MessageGetter: Exception encountered: " + e.toString());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    private class GetMessagesRequest {
        private Long conversationId;
        private int nMessages;
        private int startIndex;
        private long sinceWhen;

        public Long getConversationId() {
            return conversationId;
        }

        public void setConversationId(Long conversationId) {
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
        private long contentType;
        private long messageID;
        private long timeSent;
        private String sender;

        public Message(String content, long contentType, long messageId, long timeSent, String sender) {
            this.content = content;
            this.contentType = contentType;
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

        public Long getMessageId() {
            return messageID;
        }

        public void setMessageId(Long messageId) {
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

        public long getContentType() {
            return contentType;
        }

        public void setContentType(long contentType) {
            this.contentType = contentType;
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
