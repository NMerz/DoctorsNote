import DoctorsNote.UserInfoGetter;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Before;
import org.junit.Test;
import org.junit.Assert;
import org.mockito.Mockito;

import java.util.HashMap;

public class UserInfoGetterTest {
    Context contextMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
    }

    private HashMap getSampleMap() {
        HashMap<String, HashMap> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("uid", "6f290288-afe5-4912-b200-204709232288");
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "sub-123");
        topMap.put("context", context);
        return topMap;
    }

    @Test()
    public void testEmptyInputs() {
        UserInfoGetter userInfoGetter = new UserInfoGetter();
        Assert.assertEquals(null, userInfoGetter.get(new HashMap<>(), contextMock));
    }

    @Test()
    public void testMissingInput() {
        HashMap incompleteMap = getSampleMap();
        ((HashMap) incompleteMap.get("body-json")).remove("uid");
        UserInfoGetter userInfoGetter = new UserInfoGetter();
        Assert.assertEquals(null, userInfoGetter.get(incompleteMap, contextMock));
    }

    @Test()
    public void testCompleteInput() {
        HashMap completeMap = getSampleMap();
        UserInfoGetter userInfoGetter = new UserInfoGetter();
        Assert.assertNotNull(userInfoGetter.get(completeMap, contextMock));
    }
}
