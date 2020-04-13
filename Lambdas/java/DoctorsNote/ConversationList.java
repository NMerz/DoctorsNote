package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.sql.SQLException;
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

    public ListConversations.ConversationListResponse handleRequest(Map<String,Object> inputMap, Context context) {
        try {
            ListConversations listConversations = makeListConversations();
            ListConversations.ConversationListResponse response = listConversations.list(inputMap, context);
            if (response == null) {
                System.out.println("ConversationList: ListConversations returned null");
                throw new RuntimeException("Server experienced an error");
            }
            System.out.println("ConversationList: ListConversations returned valid response");
            return response;
        } catch (SQLException e) {
            // This should only execute if closing the connection failed
            System.out.println("ConversationList: Could not close the database connection");
            return null;
        }
    }

    public ListConversations makeListConversations() {
        System.out.println("ConversationList: Instantiating ListConversations");
        return new ListConversations(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        System.out.println("ConversationList: Executing main() (THIS SHOULD NEVER HAPPEN)");
        throw new IllegalStateException();
    }
}
