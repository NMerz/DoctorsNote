Use DoctorsNote;
DELIMITER $$
CREATE procedure FillPersonalInformation(
  finishInt INT
)
begin
  DECLARE counter INT default 0;
  DECLARE namestr VARCHAR(15);
  DECLARE addressRows INT;
  DECLARE addressID int(11);
  DECLARE birthDate date default CURRENT_DATE;
  DECLARE sex VARCHAR(1);
  DECLARE randint INT;
  
  SELECT count(*) From `Personal Information` INTO counter;
  SET counter = counter + 1;
  SELECT count(*) FROM Address INTO addressRows;
  
  WHILE counter <= finishINT DO
    SET namestr = lpad(conv(floor(rand()*pow(36,6)), 10, 36), 6, 0);
    SET randint = RAND();
    IF (randint > 0.5) THEN
      SET sex = 'M';
    ELSE
	  SET sex = 'F';
	END IF;
    SET addressID = floor(RAND() * addressRows) + 1;
    INSERT INTO DoctorsNote.`Personal Information`(personalInformationID, Name, `Birth Date`, Sex, addressID) 
    VALUES (counter, namestr, birthDate, sex, addressID);
    Set counter = counter + 1;
  END WHILE;
  

END$$
DELIMITER ;



