package DoctorsNote;

/*
 * Logic to process getting events from the database.
 * NOTE: The passed connection will be closed
 */

import com.amazonaws.services.lambda.runtime.Context;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Map;

public class EventGetter {
    private final String getEventsFormatString = "SELECT * FROM Calendar WHERE withID = ? OR userID = ?;";
    Connection dbConnection;

    public EventGetter(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public GetEventsResponse get(Map<String, Object> inputMap, Context context) {
        try {
            String userId = (String)((Map<String,Object>) inputMap.get("context")).get("sub");

            PreparedStatement statement = dbConnection.prepareStatement(getEventsFormatString);
            System.out.println("EventGetter: Getting events on behalf of " + userId);
            statement.setString(1, userId);
            statement.setString(2, userId);
            System.out.println("EventGetter: statement: " + statement);
            ResultSet eventRS = statement.executeQuery();

            // Disconnect connection with shortest lifespan possible

            // Processing results
            ArrayList<Event> events = new ArrayList<>();
            while (eventRS.next()) {
                String appointmentID = eventRS.getString(1);
                long timeScheduled = eventRS.getTimestamp(2).toInstant().toEpochMilli();
                String withID = eventRS.getString(3);
                int status = eventRS.getInt(5);
                String content = eventRS.getString(6);

                events.add(new Event(appointmentID, timeScheduled, withID, content, status));

                eventRS.updateInt(5, 0);
                eventRS.updateRow();
            }

            System.out.println(String.format("EventGetter: Returning %d events for %s",
                    events.size(),
                    context.getIdentity().getIdentityId()));

            dbConnection.close();

            Event[] tempArray = new Event[events.size()];
            return new GetEventsResponse(events.toArray(tempArray));
        } catch (Exception e) {
            System.out.println("EventGetter: Exception encountered: " + e.getMessage());
            return null;
        }
    }

    public class Event {
        private String appointmentID;
        private long timeScheduled;
        private String withID;
        private String content;
        private int status;

        public Event(String appointmentID, long timeScheduled, String withID, String content, int status) {
            this.appointmentID = appointmentID;
            this.timeScheduled = timeScheduled;
            this.withID = withID;
            this.content = content;
            this.status = status;
        }

        public String getAppointmentID() {
            return appointmentID;
        }

        public void setAppointmentID(String appointmentID) {
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

    public class GetEventsResponse {
        private Event[] events;

        public GetEventsResponse(Event[] events) {
            this.events = events;
        }

        public Event[] getEvents() {
            return events;
        }

        public void setEvents(Event[] events) {
            this.events = events;
        }
    }
}
