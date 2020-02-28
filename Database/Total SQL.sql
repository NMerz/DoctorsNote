-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema DoctorsNote
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema DoctorsNote
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `DoctorsNote` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;
USE `DoctorsNote` ;

-- -----------------------------------------------------
-- Table `DoctorsNote`.`Address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Address` (
  `addressID` INT(11) NOT NULL,
  `Street1` VARCHAR(45) NULL DEFAULT NULL,
  `Street2` VARCHAR(45) NULL DEFAULT NULL,
  `City` VARCHAR(45) NULL DEFAULT NULL,
  `State` VARCHAR(2) NULL DEFAULT NULL COMMENT 'State code of two letters e.g. OH\\n\\nMight need to change this for foreign countries.',
  `Country` VARCHAR(45) NULL DEFAULT NULL,
  `PostalCode` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`addressID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Conversation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Conversation` (
  `conversationID` INT(11) NOT NULL AUTO_INCREMENT,
  `conversationName` VARCHAR(45) NULL DEFAULT NULL,
  `lastMessageTime` DATETIME(3) NULL DEFAULT NULL,
  `status` TINYINT(4) NULL DEFAULT NULL,
  PRIMARY KEY (`conversationID`))
ENGINE = InnoDB
AUTO_INCREMENT = 17
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Personal Information`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Personal Information` (
  `personalInformationID` INT(11) NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Birth Date` DATE NULL DEFAULT NULL,
  `Sex` VARCHAR(10) NULL DEFAULT NULL,
  `Phone Number` INT(11) NULL DEFAULT NULL,
  `addressID` INT(11) NOT NULL,
  PRIMARY KEY (`personalInformationID`, `addressID`),
  CONSTRAINT `fk_Personal Information_Address1`
    FOREIGN KEY (`addressID`)
    REFERENCES `DoctorsNote`.`Address` (`addressID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;



-- -----------------------------------------------------
-- Table `DoctorsNote`.`Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Patient` (
  `patientID` INT(11) NOT NULL,
  `Nickname` VARCHAR(45) NULL DEFAULT NULL,
  `Public Key` INT(11) NOT NULL,
  `Failed Logins` INT(11) NULL DEFAULT NULL,
  `Username` VARCHAR(45) NULL DEFAULT NULL,
  `personalInformationID` INT(11) NOT NULL,
  PRIMARY KEY (`patientID`, `personalInformationID`),
  CONSTRAINT `fk_Patient_PersonalInformation1`
    FOREIGN KEY (`personalInformationID`)
    REFERENCES `DoctorsNote`.`Personal Information` (`personalInformationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;



-- -----------------------------------------------------
-- Table `DoctorsNote`.`Conversation_has_User`
-- -----------------------------------------------------
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



-- -----------------------------------------------------
-- Table `DoctorsNote`.`Doctor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Doctor` (
  `doctorID` INT(11) NOT NULL AUTO_INCREMENT,
  `systemID` INT(11) NULL DEFAULT NULL,
  `Name` VARCHAR(45) NULL DEFAULT NULL,
  `Location` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`doctorID`))
ENGINE = InnoDB
AUTO_INCREMENT = 987654322
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Doctor_has_Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Doctor_has_Patient` (
  `doctorID` INT(11) NOT NULL,
  `patientID` INT(11) NOT NULL,
  PRIMARY KEY (`doctorID`, `patientID`),
  CONSTRAINT `fk_Doctor_has_Patient_Doctor1`
    FOREIGN KEY (`doctorID`)
    REFERENCES `DoctorsNote`.`Doctor` (`doctorID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Doctor_has_Patient_Patient1`
    FOREIGN KEY (`patientID`)
    REFERENCES `DoctorsNote`.`Patient` (`patientID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;



-- -----------------------------------------------------
-- Table `DoctorsNote`.`Message`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Message` (
  `messageID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `content` LONGTEXT NULL DEFAULT NULL,
  `sender` INT(10) UNSIGNED NOT NULL,
  `recipient` INT(10) UNSIGNED NOT NULL,
  `timeCreated` DATETIME NULL DEFAULT CURRENT_TIMESTAMP(),
  `conversationID` INT(11) NOT NULL,
  PRIMARY KEY (`messageID`, `conversationID`),
  CONSTRAINT `fk_Message_Conversation1`
    FOREIGN KEY (`conversationID`)
    REFERENCES `DoctorsNote`.`Conversation` (`conversationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 11
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
