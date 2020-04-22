import DoctorsNote.GetSupportGroups;
import DoctorsNote.SupportGroupGetter;
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

public class GetSupportGroupsTest {
    Context contextMock;
    GetSupportGroups getSupportGroups;
    SupportGroupGetter supportGroupGetterMock;

    @Before
    public void beforeTests() {
        contextMock = Mockito.mock(Context.class);
        getSupportGroups = spy(new GetSupportGroups());
        supportGroupGetterMock = Mockito.mock(SupportGroupGetter.class);
        doReturn(supportGroupGetterMock).when(getSupportGroups).makeSupportGroupGetter();
    }

    @Test
    public void testValidReturn() throws SQLException {
        SupportGroupGetter.GetSupportGroupsResponse responseMock = Mockito.mock(SupportGroupGetter.GetSupportGroupsResponse.class);
        when(supportGroupGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(responseMock);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();
        Assert.assertEquals(responseMock, getSupportGroups.handleRequest(inputMap, contextMock));
    }

    @Test
    public void testInvalidReturn() throws SQLException {
        when(supportGroupGetterMock.get(Mockito.anyMap(), Mockito.any())).thenReturn(null);
        HashMap<String, Object> inputMap = new HashMap<String, Object>();

        try {
            getSupportGroups.handleRequest(inputMap, contextMock);
            Assert.fail();
        } catch (RuntimeException e) {
            Assert.assertEquals("Server experienced an error", e.getMessage());
        }
    }
}
