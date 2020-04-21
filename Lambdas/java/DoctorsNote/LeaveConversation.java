package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for removing users from a conversation.
 *
 * Note: If the user is the last user left in a conversation when they are removed from it,
 *       the conversation will still exist in a zombie state with zero members.
 *
 * Expects: A valid input map containing conversationId (String) and userId (String) in the body
 * Returns: A JSON string that maps from a POJO of type LeaveConversationResponse.
 *
 * Error Handling: Throws a runtime exception if an unrecoverable exception occurs
 */
public class LeaveConversation implements RequestHandler<Map<String,Object>, ConversationLeaver.LeaveConversationResponse> {

    @Override
    public ConversationLeaver.LeaveConversationResponse handleRequest(Map<String,Object> inputMap, Context context) {

        try {
            ConversationLeaver conversationLeaver = makeConversationLeaver();
            ConversationLeaver.LeaveConversationResponse response = conversationLeaver.leave(inputMap, context);
            if (response == null) {
                System.out.println("LeaveConversation: ConversationLeaver returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("LeaveConversation: ConversationLeaver returned valid response");
            return response;
        }  catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("LeaveConversation: Could not close the database connection");
            return null;
        }
    }

    public ConversationLeaver makeConversationLeaver() {
        System.out.println("LeaveConversation: Instantiating ConversationLeaver");
        return new ConversationLeaver(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("LeaveConversation: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
