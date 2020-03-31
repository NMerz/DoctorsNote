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
    private final String getEventsFormatString = "SELECT * FROM Calendar WHERE userID = ?;";
    Connection dbConnection;

    public EventGetter(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public GetEventsResponse get(Map<String, Object> inputMap, Context context) {
        try {
            PreparedStatement statement = dbConnection.prepareStatement(getEventsFormatString);
            System.out.println("EventGetter: Getting events on behalf of " + context.getIdentity().getIdentityId());
            statement.setString(1, context.getIdentity().getIdentityId());
            System.out.println("EventGetter: statement: " + statement);
            ResultSet eventRS = statement.executeQuery();

            // Disconnect connection with shortest lifespan possible

            // Processing results
            ArrayList<Event> events = new ArrayList<>();
            while (eventRS.next()) {
                String eventId = eventRS.getString(1);
                long startTime = eventRS.getTimestamp(2).toInstant().getEpochSecond();
                long endTime = eventRS.getTimestamp(3).toInstant().getEpochSecond();
                String location = eventRS.getString(4);
                String title = eventRS.getString(5);
                String description = eventRS.getString(6);

                events.add(new Event(eventId, startTime, endTime, location, title, description));
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
        private String eventId;
        private long startTime;
        private long endTime;
        private String location;
        private String title;
        private String description;

        public Event(String eventId, long startTime, long endTime, String location, String title, String description) {
            this.eventId = eventId;
            this.startTime = startTime;
            this.endTime = endTime;
            this.location = location;
            this.title = title;
            this.description = description;
        }

        public String getEventId() {
            return eventId;
        }

        public void setEventId(String eventId) {
            this.eventId = eventId;
        }

        public long getStartTime() {
            return startTime;
        }

        public void setStartTime(long startTime) {
            this.startTime = startTime;
        }

        public long getEndTime() {
            return endTime;
        }

        public void setEndTime(long endTime) {
            this.endTime = endTime;
        }

        public String getLocation() {
            return location;
        }

        public void setLocation(String location) {
            this.location = location;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
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
