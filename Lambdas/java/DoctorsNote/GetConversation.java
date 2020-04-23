package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
import java.util.Map;

/*
 * A Lambda handler for getting support group details.
 *
 * Expects: A valid context and an input map containing a conversationId.
 * Returns: A Conversation object.
 *
 * Error Handling: Returns null or a RuntimeException if an unrecoverable error is encountered
 */
public class GetConversation implements RequestHandler<Map<String,Object>, Conversation> {

    public Conversation handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            ConversationGetter conversationGetter = makeConversationGetter();
            Conversation response = conversationGetter.get(inputMap, context);
            if (response == null) {
                System.out.println("GetConversation: ConversationGetter returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("GetConversation: ConversationGetter returned valid response");
            return response;
        } catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("GetConversation: Could not close the database connection");
            return null;
        }
    }

    public ConversationGetter makeConversationGetter() {
        System.out.println("GetConversation: Instantiating ConversationGetter");
        return new ConversationGetter(Connector.getConnection());
    }

    public static void main(String[] args) {
        System.out.println("GetConversation: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
