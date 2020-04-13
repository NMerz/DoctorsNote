package DoctorsNote;

/*
 * Logic to process getting reminders from the database.
 * NOTE: The passed connection will be closed
 */

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Map;

public class ReminderGetter {
    private final String getRemindersFormatString = "SELECT * FROM Reminder WHERE remindedID = ? ORDER BY reminderID DESC;";
    Connection dbConnection;

    public ReminderGetter(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public GetReminderResponse get(Map<String, Object> inputMap, Context context) throws SQLException {
        try {
            PreparedStatement statement = dbConnection.prepareStatement(getRemindersFormatString);
            System.out.println("ReminderGetter: Getting reminders on behalf of " + (String)((Map<String,Object>) inputMap.get("context")).get("sub"));
            statement.setString(1, (String)((Map<String,Object>) inputMap.get("context")).get("sub"));
            //statement.setTimestamp(2, new Timestamp(Long.parseLong(((Map<String,Object>) inputMap.get("body-json")).get("sinceWhen").toString())));
            System.out.println("ReminderGetter: statement: " + statement);

            ResultSet reminderRS = statement.executeQuery();


            // Processing results
            ArrayList<Reminder> reminders = new ArrayList<>();
            while (reminderRS.next()) {
                int reminderID = reminderRS.getInt(1);
                String content = reminderRS.getString(2);
                String remindee = reminderRS.getString(3);
                String creatorID = reminderRS.getString(4);
                long timeCreated = reminderRS.getTimestamp(5).toInstant().toEpochMilli();
                int intradayFrequency = reminderRS.getInt(6);
                int daysBetweenReminders = reminderRS.getInt(7);
                String descriptionContent = reminderRS.getString(8);

//                if (alertTime >= 0) {
                reminders.add(new Reminder(reminderID, content, descriptionContent, remindee, creatorID,  intradayFrequency, daysBetweenReminders, timeCreated));
//                }
            }

            System.out.println(String.format("ReminderGetter: Returning %d reminders for %s",
                    reminders.size(),
                    ((Map<String,Object>) inputMap.get("context")).get("sub")));

            Reminder[] tempArray = new Reminder[reminders.size()];
            return new GetReminderResponse(reminders.toArray(tempArray));
        } catch (Exception e) {
            System.out.println("ReminderGetter: Exception encountered: " + e.getMessage());
            return null;
        } finally {
            dbConnection.close();
        }
    }

    public class Reminder {
        private int reminderID;
        private String content;
        private String descriptionContent;
        private String remindee;
        private String creatorID;
        private int intradayFrequency;
        private int daysBetweenReminders;
        private long timeCreated;

        public Reminder(int reminderID, String content, String descriptionContent, String remindee, String creatorID, int intradayFequency, int daysBetweenReminders, long timeCreated) {
            this.reminderID = reminderID;
            this.remindee = remindee;
            this.creatorID = creatorID;
            this.content = content;
            this.descriptionContent = descriptionContent;
            this.intradayFrequency = intradayFequency;
            this.daysBetweenReminders = daysBetweenReminders;
            this.timeCreated = timeCreated;
        }

        public int getReminderID() {
            return reminderID;
        }

        public void setReminderID(int reminderID) {
            this.reminderID = reminderID;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public String getDescriptionContent() {
            return descriptionContent;
        }

        public void setDescriptionContent(String descriptionContent) {
            this.descriptionContent = descriptionContent;
        }

        public long getTimeCreated() {
            return timeCreated;
        }

        public void setTimeCreated(long alertTime) {
            this.timeCreated = alertTime;
        }

        public int getIntradayFrequency() {
            return intradayFrequency;
        }

        public void setIntradayFrequency(int intradayFrequency) {
            this.intradayFrequency = intradayFrequency;
        }

        public int getDaysBetweenReminders() {
            return daysBetweenReminders;
        }

        public void setDaysBetweenReminders(int daysBetweenReminders) {
            this.daysBetweenReminders = daysBetweenReminders;
        }

        public String getRemindee() {
            return remindee;
        }

        public void setRemindee(String remindee) {
            this.remindee = remindee;
        }

        public String getCreatorID() {
            return creatorID;
        }

        public void setCreatorID(String creatorID) {
            this.creatorID = creatorID;
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
