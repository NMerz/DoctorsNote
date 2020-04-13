package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

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
        ListConversations listConversations = makeListConversations();
        ListConversations.ConversationListResponse response = listConversations.list(inputMap, context);
        if (response == null) {
            throw new RuntimeException("Server experienced an error");
        }
        return response;
    }

    public ListConversations makeListConversations() {
        return new ListConversations(Connector.getConnection());
    }

    public static void main(String[] args) throws IllegalStateException {
        throw new IllegalStateException();
    }
}
