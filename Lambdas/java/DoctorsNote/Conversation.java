package DoctorsNote;

public class Conversation {
    private String conversationName;
    private int conversationID;
    private String converserPublicKey;
    private String adminPublicKey;
    private String converserID;
    private int status;
    private long lastMessageTime;        // In UNIX time stamp. Should be long; int expires in 2038
    private int numMembers;
    private String description;

    public Conversation(String conversationName, String conversationID, String converserID, String converserPublicKey, String adminPublicKey, int status, long lastMessageTime, int numMembers, String description) {

        this.conversationName = conversationName;
        this.conversationID = Integer.parseInt(conversationID);
        this.converserPublicKey = converserPublicKey;
        this.adminPublicKey = adminPublicKey;
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
