CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Conversation_has_User` (
  `conversationID` INT(11) NOT NULL,
  `userID` INT(11) NOT NULL,
  PRIMARY KEY (`conversationID`, `userID`),
  CONSTRAINT `fk_Conversation_has_User_Conversation1`
    FOREIGN KEY (`conversationID`)
    REFERENCES `DoctorsNote`.`Conversation` (`conversationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Conversation_has_User_Patient1`
    FOREIGN KEY (`userID`)
    REFERENCES `DoctorsNote`.`Patient` (`patientID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;



