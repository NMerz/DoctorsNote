Use DoctorsNote;
DELIMITER $$
CREATE procedure FillAddresses(
  finishInt INT
)
begin
  DECLARE counter INT default 0;
  DECLARE street1 VARCHAR(6);
  DECLARE street2 VARCHAR(6);
  DECLARE city VARCHAR(6);
  DECLARE state VARCHAR(2);
  DECLARE country VARCHAR(3);
  DECLARE postalCode INT(6);
  
  SELECT count(*) From Address INTO counter;
  SET counter = counter + 1;
  
  WHILE counter <= finishINT DO
    SET street1 = lpad(conv(floor(rand()*pow(36,6)), 10, 36), 6, 0);
    SET street2 = lpad(conv(floor(rand()*pow(36,6)), 10, 36), 6, 0);
    SET city = lpad(conv(floor(rand()*pow(36,6)), 10, 36), 6, 0);
    SET state = lpad(conv(floor(rand()*pow(36,2)), 10, 36), 2, 0);
    SET country = lpad(conv(floor(rand()*pow(36,3)), 10, 36), 3, 0);
    SET postalCode = floor(rand() * 100);
    INSERT INTO DoctorsNote.Address(addressID, Street1, Street2, City, State, Country, PostalCode) 
    VALUES (counter, street1, street2, city, state, country, postalCode);
    Set counter = counter + 1;
  END WHILE;
  

END$$
DELIMITER ;



