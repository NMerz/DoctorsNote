package DoctorsNote;

/*
 * Logic to process getting reminders from the database.
 * NOTE: The passed connection will be closed
 */

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Map;

public class ReminderGetter {
    private final String getRemindersFormatString = "SELECT * FROM Reminder WHERE remindedID = ? AND timeCreated >= ?;";
    Connection dbConnection;

    public ReminderGetter(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public GetReminderResponse get(Map<String, Object> inputMap, Context context) {
        try {
            PreparedStatement statement = dbConnection.prepareStatement(getRemindersFormatString);
            statement.setString(1, (String)((Map<String,Object>) inputMap.get("context")).get("sub"));
            statement.setTimestamp(2, new Timestamp(Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("since").toString())));
            System.out.println(statement);
            ResultSet reminderRS = statement.executeQuery();

            // Disconnect connection with shortest lifespan possible
            dbConnection.close();

            // Processing results
            ArrayList<Reminder> reminders = new ArrayList<>();
            while (reminderRS.next()) {
                String reminderID = reminderRS.getString(1);
                String content = reminderRS.getString(2);
                long alertTime = reminderRS.getTimestamp(6).toInstant().getEpochSecond();

                if (alertTime >= 0) {
                    reminders.add(new Reminder(reminderID, content, alertTime));
                }
            }

            Reminder[] tempArray = new Reminder[reminders.size()];
            return new GetReminderResponse(reminders.toArray(tempArray));
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    public class Reminder {
        private String reminderID;
        private String content;
        private long alertTime;

        public Reminder(String reminderID, String content, long alertTime) {
            this.reminderID = reminderID;
            this.content = content;
            this.alertTime = alertTime;
        }

        public String getReminderID() {
            return reminderID;
        }

        public void setReminderID(String reminderID) {
            this.reminderID = reminderID;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public long getAlertTime() {
            return alertTime;
        }

        public void setAlertTime(long alertTime) {
            this.alertTime = alertTime;
        }
    }

    public class GetReminderResponse {
        private Reminder[] reminders;

        public GetReminderResponse(Reminder[] reminders) {
            this.reminders = reminders;
        }

        public Reminder[] getReminders() {
            return reminders;
        }

        public void setReminders(Reminder[] reminders) {
            this.reminders = reminders;
        }
    }
}
