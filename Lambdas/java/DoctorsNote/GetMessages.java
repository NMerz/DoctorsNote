package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.Map;

/*
 * A Lambda handler for getting the most recent N messages in a given conversation.
 *
 * Expects: A JSON string that maps to a POJO of type GetOldMessagesRequest
 * Returns: A JSON string that maps from a POJO of type GetOldMessagesResponse
 *
 * Error Handling: Returns null if an unrecoverable error is encountered
 */
public class GetMessages implements RequestHandler<Map<String,Object>, MessageGetter.GetMessagesResponse> {

    public MessageGetter.GetMessagesResponse handleRequest(Map<String,Object> inputMap, Context context) {
        MessageGetter messageGetter = makeMessageGetter();
        MessageGetter.GetMessagesResponse response = messageGetter.get(inputMap, context);
        if (response == null) {
            throw new RuntimeException("Server experienced an error");
        }
        return response;
    }

    public MessageGetter makeMessageGetter() {
        return new MessageGetter(Connector.getConnection());
    }

    public static void main(String[] args) {
        throw new IllegalStateException();
    }
}
