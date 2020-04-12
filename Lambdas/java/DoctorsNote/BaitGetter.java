package DoctorsNote;

/*
 * Test class to test for SQL injection. Modeled after BaitAdder.
 * NOTE: The passed connection will be closed
 */

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Map;

public class BaitGetter {
    private final String getBaitsFormatString = "SELECT * FROM Bait WHERE withID = ? OR userID = ?;";
    Connection dbConnection;

    public BaitGetter(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public GetBaitsResponse get(Map<String, Object> inputMap, Context context) {
        try {
            String userId = (String)((Map<String,Object>) inputMap.get("context")).get("sub");

            PreparedStatement statement = dbConnection.prepareStatement(getBaitsFormatString);
            System.out.println("BaitGetter: Getting baits on behalf of " + userId);
            statement.setString(1, userId);
            statement.setString(2, userId);
            System.out.println("BaitGetter: statement: " + statement);
            ResultSet baitRS = statement.executeQuery();

            // Disconnect connection with shortest lifespan possible

            // Processing results
            ArrayList<Bait> baits = new ArrayList<>();
            while (baitRS.next()) {
                Long appointmentID = baitRS.getLong(1);
                long timeScheduled = baitRS.getTimestamp(2).toInstant().toEpochMilli();
                String withID = baitRS.getString(3);
                String userID = baitRS.getString(4);
                int status = baitRS.getInt(5);
                String content = baitRS.getString(6);

                baits.add(new Bait(appointmentID, timeScheduled, (withID.equals(userId) ? userID : withID), content, status));

                //baitRS.updateInt(5, 0);
                //baitRS.updateRow();
            }

            System.out.println(String.format("BaitGetter: Returning %d baits",
                    baits.size()));

            dbConnection.close();

            Bait[] tempArray = new Bait[baits.size()];
            return new GetBaitsResponse(baits.toArray(tempArray));
        } catch (Exception e) {
            System.out.println("BaitGetter: Exception encountered: " + e.getMessage());
            return null;
        }
    }

    public class Bait {
        private long appointmentID;
        private long timeScheduled;
        private String withID;
        private String content;
        private int status;

        public Bait(long appointmentID, long timeScheduled, String withID, String content, int status) {
            this.appointmentID = appointmentID;
            this.timeScheduled = timeScheduled;
            this.withID = withID;
            this.content = content;
            this.status = status;
        }

        public long getAppointmentID() {
            return appointmentID;
        }

        public void setAppointmentID(long appointmentID) {
            this.appointmentID = appointmentID;
        }

        public long getTimeScheduled() {
            return timeScheduled;
        }

        public void setTimeScheduled(long timeScheduled) {
            this.timeScheduled = timeScheduled;
        }

        public String getWithID() {
            return withID;
        }

        public void setWithID(String withID) {
            this.withID = withID;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public int getStatus() {
            return status;
        }

        public void setStatus(int status) {
            this.status = status;
        }
    }

    public class GetBaitsResponse {
        private Bait[] baits;

        public GetBaitsResponse(Bait[] baits) {
            this.baits = baits;
        }

        public Bait[] getBaits() {
            return baits;
        }

        public void setBaits(Bait[] baits) {
            this.baits = baits;
        }
    }
}
