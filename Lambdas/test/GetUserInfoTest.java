import DoctorsNote.GetUserInfo;
import DoctorsNote.UserInfoGetter;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;

import java.sql.SQLException;
import java.util.HashMap;

import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

public class GetUserInfoTest {
    Context contextMock;
    GetUserInfo getUserInfo;
    UserInfoGetter userInfoGetterMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        getUserInfo = spy(new GetUserInfo());
        userInfoGetterMock = Mockito.mock(UserInfoGetter.class);
        doReturn(userInfoGetterMock).when(getUserInfo).makeUserInfoGetter();
    }

    @Test
    public void testValidReturn() throws SQLException {
        UserInfoGetter.UserInfoResponse responseMock = Mockito.mock(UserInfoGetter.UserInfoResponse.class);
        when(userInfoGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, getUserInfo.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(userInfoGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            getUserInfo.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
