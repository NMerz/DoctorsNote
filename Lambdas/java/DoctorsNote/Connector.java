package DoctorsNote;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Connector {
    public static Connection getConnection() {
        try {
            DBCredentialsProvider dbCP = new DBCredentialsProvider();
            Class.forName(dbCP.getDBDriver());     // Loads and registers the driver
            return DriverManager.getConnection(dbCP.getDBURL(),
                    dbCP.getDBUsername(),
                    dbCP.getDBPassword());
        } catch (IOException | SQLException | ClassNotFoundException e) {
            throw new NullPointerException("Failed to load connection");
        }
    }
}
