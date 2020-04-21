package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for adding users to a conversation.
 *
 * Note: If the conversation referenced in the passed conversation id does not exist, the update will fail.
 *
 * Expects: A valid input map containing conversationId (String) and userId (String) in the body
 * Returns: A JSON string that maps from a POJO of type JoinConversationResponse.
 *
 * Error Handling: Throws a runtime exception if an unrecoverable exception occurs
 */
public class JoinConversation implements RequestHandler<Map<String,Object>, ConversationJoiner.JoinConversationResponse> {

    @Override
    public ConversationJoiner.JoinConversationResponse handleRequest(Map<String,Object> inputMap, Context context) {

        try {
            ConversationJoiner conversationJoin = makeConversationJoiner();
            ConversationJoiner.JoinConversationResponse response = conversationJoin.join(inputMap, context);
            if (response == null) {
                System.out.println("JoinConversation: ConversationJoiner returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("JoinConversation: ConversationJoiner returned valid response");
            return response;
        }  catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("JoinConversation: Could not close the database connection");
            return null;
        }
    }

    public ConversationJoiner makeConversationJoiner() {
        System.out.println("JoinConversation: Instantiating ConversationJoiner");
        return new ConversationJoiner(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("JoinConversation: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
