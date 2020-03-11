import DoctorsNote.DBCredentialsProvider;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.Assert;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBCredentialsProviderTest {
    private static DBCredentialsProvider dbcp;

    @BeforeClass
    public static void BeforeClass() {
        try {
            dbcp = new DBCredentialsProvider();
        } catch (IOException e) {
            Assert.fail();
        }
    }

    @Test
    public void getDBProvider() {
        String actual = dbcp.getDBProvider();
        Assert.assertNotNull(actual);
        Assert.assertNotEquals("", actual);
    }

    @Test
    public void getDBEndpoint() {
        String actual = dbcp.getDBEndpoint();
        Assert.assertNotNull(actual);
        Assert.assertNotEquals("", actual);
    }

    @Test
    public void getDBPort() {
        String actual = dbcp.getDBPort();
        Assert.assertNotNull(actual);
        Assert.assertNotEquals("", actual);
    }

    @Test
    public void getDBURL() {
        String actual = dbcp.getDBURL();
        Assert.assertNotNull(actual);
        Assert.assertNotEquals("", actual);
    }

    @Test
    public void getDBUsername() {
        String actual = dbcp.getDBUsername();
        Assert.assertNotNull(actual);
        Assert.assertNotEquals("", actual);
    }

    @Test
    public void getDBPassword() {
        String actual = dbcp.getDBPassword();
        Assert.assertNotNull(actual);
        Assert.assertNotEquals("", actual);
    }

    @Test
    public void getDBName() {
        String actual = dbcp.getDBName();
        Assert.assertNotNull(actual);
        Assert.assertNotEquals("", actual);
    }

    @Test
    public void getDBDriver() {
        String actual = dbcp.getDBDriver();
        Assert.assertNotNull(actual);
        Assert.assertNotEquals("", actual);
    }

    @Test
    public void testConnection() {
        try {
            DBCredentialsProvider dbCP = new DBCredentialsProvider();
            Class.forName(dbCP.getDBDriver());     // Loads and registers the driver
            Connection connection = DriverManager.getConnection(dbCP.getDBURL(),
                    dbCP.getDBUsername(),
                    dbCP.getDBPassword());

            Assert.assertTrue(connection.isValid(5));
            connection.close();
        } catch (IOException | SQLException | ClassNotFoundException e) {
            Assert.fail();
        }
    }
}
