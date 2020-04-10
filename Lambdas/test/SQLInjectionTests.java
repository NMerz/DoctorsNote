import DoctorsNote.BaitAdder;
import DoctorsNote.BaitGetter;
import DoctorsNote.Connector;
import com.amazonaws.services.lambda.runtime.Context;
import org.junit.Assert;
import org.junit.Test;

import java.sql.SQLException;
import java.util.HashMap;

import static org.mockito.Mockito.mock;

/*
 * Note: These connections are live and will damage the database if done wrong
 */

public class SQLInjectionTests {
    @Test()
    public void testStackingQueries() throws SQLException {
        HashMap<String, Object> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("content", "Sample content");
        jsonBody.put("timeScheduled", 20L);
        jsonBody.put("withID", "sample-id");
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "sub-id123; DROP TABLE Bait;--");    // <<<<< Malicious Value
        topMap.put("context", context);
        topMap.put("context", context);

        BaitAdder baitAdder = new BaitAdder(Connector.getConnection("Lambdas/res/DBCredentials.tsv"));
        Assert.assertNotNull(baitAdder.add(topMap, mock(Context.class)));

        baitAdder = new BaitAdder(Connector.getConnection("Lambdas/res/DBCredentials.tsv"));
        // If the table was dropped, this call would fail
        Assert.assertNotNull(baitAdder.add(topMap, mock(Context.class)));
    }

    @Test()
    public void testConditionalInjection() throws SQLException {
        HashMap<String, Object> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("since", 1L);
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "12345678 OR 1=1");         // <<<<< Malicious Value
        topMap.put("context", context);

        Context contextMock = mock(Context.class);

        BaitGetter baitGetter = new BaitGetter(Connector.getConnection("Lambdas/res/DBCredentials.tsv"));
        BaitGetter.GetBaitsResponse response = baitGetter.get(topMap, contextMock);
        Assert.assertNotNull(response);
        Assert.assertEquals(0, response.getBaits().length);
    }

    @Test()
    public void testUnionInjection() throws SQLException {
        HashMap<String, Object> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("since", 1L);
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "12345678 UNION * from Calendar WHERE 1=1");  // <<<<< Malicious Value
        topMap.put("context", context);

        Context contextMock = mock(Context.class);

        BaitGetter baitGetter = new BaitGetter(Connector.getConnection("Lambdas/res/DBCredentials.tsv"));
        BaitGetter.GetBaitsResponse response = baitGetter.get(topMap, contextMock);
        Assert.assertNotNull(response);
        Assert.assertEquals(0, response.getBaits().length);
    }

    @Test()
    public void testHavingInjection() throws SQLException {
        HashMap<String, Object> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("since", 1L);
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "12345678 ' HAVING 1=1 --");  // <<<<< Malicious Value
        topMap.put("context", context);

        Context contextMock = mock(Context.class);

        BaitGetter baitGetter = new BaitGetter(Connector.getConnection("Lambdas/res/DBCredentials.tsv"));
        BaitGetter.GetBaitsResponse response = baitGetter.get(topMap, contextMock);
        Assert.assertNotNull(response);
        Assert.assertEquals(0, response.getBaits().length);
    }

    @Test()
    public void testOrderByInjection() throws SQLException {
        HashMap<String, Object> topMap = new HashMap();
        HashMap<String, Object> jsonBody = new HashMap();
        jsonBody.put("since", 1L);
        topMap.put("body-json", jsonBody);
        HashMap<String, Object> context = new HashMap();
        context.put("sub", "12345678 \"; ORDER BY 6; --");  // <<<<< Malicious Value
        topMap.put("context", context);

        Context contextMock = mock(Context.class);

        BaitGetter baitGetter = new BaitGetter(Connector.getConnection("Lambdas/res/DBCredentials.tsv"));
        BaitGetter.GetBaitsResponse response = baitGetter.get(topMap, contextMock);
        Assert.assertNotNull(response);
        Assert.assertEquals(0, response.getBaits().length);
    }
}
