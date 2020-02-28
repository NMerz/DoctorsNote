Use DoctorsNote;
DELIMITER $$
CREATE procedure FillPatient(
  finishInt INT
)
begin
  DECLARE counter INT default 0;
  DECLARE nickname VARCHAR(15);
  DECLARE piRows INT;
  DECLARE piID INT;
  DECLARE username VARCHAR(15);
  
  SELECT count(*) From Patient INTO counter;
  SET counter = counter + 1;
  SELECT count(*) FROM `Personal Information` INTO piRows;
  
  WHILE counter <= finishINT DO
    SET nickname = lpad(conv(floor(rand()*pow(36,6)), 10, 36), 6, 0);
    SET username = lpad(conv(floor(rand()*pow(36,8)), 10, 36), 8, 0);
    INSERT INTO DoctorsNote.Patient(patientID, Nickname, `Public Key`, Username, personalInformationID) 
    VALUES (counter, nickname, counter, username, counter);
    Set counter = counter + 1;
  END WHILE;
  

END$$
DELIMITER ;



