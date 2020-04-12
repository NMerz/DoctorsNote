CREATE DEFINER=`admin`@`%` PROCEDURE `FillReminder`(
  addInt INT
)
begin
  #counter
  DECLARE counter INT default 1;
  
  #IDs
  DECLARE my_reminderID INT default 0;
  DECLARE my_remindedID INT default 0;
  DECLARE max_reminderID INT default 0;
  DECLARE my_creatorID INT default 0;
  
  #Content
  DECLARE my_content longtext DEFAULT 'DEFAULT';
  
  #Dates
  DECLARE my_timeCreated DATETIME DEFAULT CURRENT_DATE();
  DECLARE my_alertTime DATETIME DEFAULT CURRENT_DATE();
  DECLARE my_year VARCHAR(4) default '1970';
  DECLARE my_month VARCHAR(2) default '00';
  DECLARE my_day VARCHAR(2) default '00';
  
  #Times
  DECLARE my_hour VARCHAR(2) DEFAULT '00';
  DECLARE my_min VARCHAR(2) DEFAULT '00';
  DECLARE my_sec VARCHAR(2) DEFAULT '00';
  
  #Frequencies
  DECLARE my_intradayFrequency INT DEFAULT 0;
  DECLARE my_daysBetweenRemindes INT DEFAULT 1;
  
  #Find starting ID number
  SELECT MAX(reminderID)
  FROM Reminder
  INTO max_reminderID;
  
  WHILE counter <= addInt DO
    SET my_reminderID = counter + max_reminderID;
    SET my_remindedID = floor(rand() * pow(10, 9));
    SET my_creatorID = floor(rand() * pow(10, 9));
    
    #set Frequencies
    SET my_intradayFrequency = FLOOR(RAND() * 1440);
    SET my_daysBetweenReminders = FLOOR(RAND() * 365);
    
    #Get the randomized date
    SET my_year = FLOOR(RAND() * 50) + 1970;
    SET my_month = FLOOR(RAND() * 12) + 1;
    SET my_day = FLOOR(RAND() * 28) + 1;
    
    #get the randomized time
    SET my_hour = FLOOR(RAND() * 24);
    SET my_min = FLOOR(RAND() * 60);
    SET my_sec = FLOOR(RAND() * 60);
    
    #concatinate datetime
    SET my_timeCreated = CAST(CONCAT(my_year, '-', my_month, '-', my_day, ' ', my_hour, ':', my_min, ':', my_sec) AS DATETIME);
    
    #repeat for alertTime
    SET my_year = FLOOR(RAND() * 50) + 1970;
    SET my_month = FLOOR(RAND() * 12) + 1;
    SET my_day = FLOOR(RAND() * 28) + 1;
    SET my_hour = FLOOR(RAND() * 24);
    SET my_min = FLOOR(RAND() * 60);
    SET my_sec = FLOOR(RAND() * 60);
    SET my_alertTime = CAST(CONCAT(my_year, '-', my_month, '-', my_day, ' ', my_hour, ':', my_min, ':', my_sec) AS DATETIME);
    
    #Insert
    INSERT INTO DoctorsNote.Reminder(reminderID, content, remindedID, creatorID, timeCreated, intradayFrequency, daysBetweenReminders)
    VALUES (my_reminderID, my_content, my_remindedID, my_creatorID, my_timeCreated, my_intradayFrequency, my_daysBetweenReminders);
    
    #Increment counter
    SET counter = counter + 1;
  END WHILE;
  

END