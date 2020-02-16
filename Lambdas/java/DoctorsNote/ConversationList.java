package DoctorsNote;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

public class ConversationList implements RequestHandler<String, String> {
    @Override
    public String handleRequest(String jsonString, Context context) {
        return null;
    }
}
