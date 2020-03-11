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
-- Table `DoctorsNote`.`Conversation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Conversation` (
  `ConversationID` INT(11) NOT NULL AUTO_INCREMENT,
  `ConversationName` VARCHAR(45) NULL DEFAULT NULL,
  `lastMessageTime` DATETIME NULL DEFAULT NULL,
  `status` TINYINT(4) NULL DEFAULT NULL,
  PRIMARY KEY (`ConversationID`))
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
  `timeCreated` DATETIME NULL DEFAULT NULL,
  `ConversationID` INT(11) NOT NULL,
  PRIMARY KEY (`messageID`, `ConversationID`),
  INDEX `fk_Message_Conversation1_idx` (`ConversationID` ASC) VISIBLE,
  CONSTRAINT `fk_Message_Conversation1`
    FOREIGN KEY (`ConversationID`)
    REFERENCES `DoctorsNote`.`Conversation` (`ConversationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Address` (
  `AddressID` INT NOT NULL,
  `Street1` VARCHAR(45) NULL,
  `Street2` VARCHAR(45) NULL,
  `City` VARCHAR(45) NULL,
  `State` VARCHAR(2) NULL COMMENT 'State code of two letters e.g. OH\n\nMight need to change this for foreign countries.',
  `Country` VARCHAR(45) NULL,
  `PostalCode` INT NULL,
  PRIMARY KEY (`AddressID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Personal Information`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Personal Information` (
  `PersonalInformationID` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(45) NOT NULL,
  `Birth Date` DATE NULL,
  `Sex` VARCHAR(10) NULL,
  `Phone Number` INT(11) NULL,
  `AddressID` INT NOT NULL,
  PRIMARY KEY (`PersonalInformationID`, `AddressID`),
  INDEX `fk_Personal Information_Address1_idx` (`AddressID` ASC) VISIBLE,
  CONSTRAINT `fk_Personal Information_Address1`
    FOREIGN KEY (`AddressID`)
    REFERENCES `DoctorsNote`.`Address` (`AddressID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Patient` (
  `PatientID` INT NOT NULL,
  `Nickname` VARCHAR(45) NULL,
  `Public Key` INT NOT NULL,
  `Failed Logins` INT NULL,
  `Username` VARCHAR(45) NULL,
  `PersonalInformationID` INT NOT NULL,
  PRIMARY KEY (`PatientID`, `PersonalInformationID`),
  INDEX `fk_Patient_Personal Information1_idx` (`PersonalInformationID` ASC) VISIBLE,
  CONSTRAINT `fk_Patient_Personal Information1`
    FOREIGN KEY (`PersonalInformationID`)
    REFERENCES `DoctorsNote`.`Personal Information` (`PersonalInformationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Conversation_has_User`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Conversation_has_User` (
  `Conversation_ConversationID` INT(11) NOT NULL,
  `Patient_PatientID` INT NOT NULL,
  `Patient_PersonalInformationID` INT NOT NULL,
  PRIMARY KEY (`Conversation_ConversationID`, `Patient_PatientID`, `Patient_PersonalInformationID`),
  INDEX `fk_Conversation_has_Patient_Patient1_idx` (`Patient_PatientID` ASC, `Patient_PersonalInformationID` ASC) VISIBLE,
  INDEX `fk_Conversation_has_Patient_Conversation1_idx` (`Conversation_ConversationID` ASC) VISIBLE,
  CONSTRAINT `fk_Conversation_has_Patient_Conversation1`
    FOREIGN KEY (`Conversation_ConversationID`)
    REFERENCES `DoctorsNote`.`Conversation` (`ConversationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Conversation_has_Patient_Patient1`
    FOREIGN KEY (`Patient_PatientID` , `Patient_PersonalInformationID`)
    REFERENCES `DoctorsNote`.`Patient` (`PatientID` , `PersonalInformationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
