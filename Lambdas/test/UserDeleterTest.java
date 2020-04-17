import DoctorsNote.UserDeleter;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;
import org.mockito.Mockito;

import java.util.HashMap;

public class UserDeleterTest {
    Context contextMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
    }

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("uid", "test-uid");
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "sub-123");
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testEmptyInputs() {
        UserDeleter userDeleter = new UserDeleter();
        Assert.assertEquals(null, userDeleter.delete(new HashMap<>(), contextMock));
    }

    @Test()
    public void testMissingInput() {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("uid");
        UserDeleter userDeleter = new UserDeleter();
        Assert.assertEquals(null, userDeleter.delete(incompleteMap, contextMock));
    }

    @Test()
    public void testCompleteInputFakeUser() {
        HashMap completeMap = getSampleMap();
        UserDeleter userDeleter = new UserDeleter();
        Assert.assertNull(userDeleter.delete(completeMap, contextMock));
    }
}
