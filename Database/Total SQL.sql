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
  `conversationID` INT(11) NOT NULL AUTO_INCREMENT,
  `conversationName` VARCHAR(45) NULL DEFAULT NULL,
  `lastMessageTime` DATETIME NULL DEFAULT NULL,
  `status` TINYINT(4) NULL DEFAULT NULL,
  PRIMARY KEY (`conversationID`))
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
  `conversationID` INT(11) NOT NULL,
  PRIMARY KEY (`messageID`, `conversationID`),
  CONSTRAINT `fk_Message_Conversation1`
    FOREIGN KEY (`conversationID`)
    REFERENCES `DoctorsNote`.`Conversation` (`conversationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;

-- -----------------------------------------------------
-- Table `DoctorsNote`.`Address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Address` (
  `addressID` INT NOT NULL,
  `Street1` VARCHAR(45) NULL,
  `Street2` VARCHAR(45) NULL,
  `City` VARCHAR(45) NULL,
  `State` VARCHAR(2) NULL COMMENT 'State code of two letters e.g. OH\n\nMight need to change this for foreign countries.',
  `Country` VARCHAR(45) NULL,
  `PostalCode` INT NULL,
  PRIMARY KEY (`addressID`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `DoctorsNote`.`Personal Information`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Personal Information` (
  `personalInformationID` INT NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Birth Date` DATE NULL,
  `Sex` VARCHAR(10) NULL,
  `Phone Number` INT(11) NULL,
  `addressID` INT NOT NULL,
  PRIMARY KEY (`personalInformationID`, `addressID`),
  CONSTRAINT `fk_Personal Information_Address1`
    FOREIGN KEY (`addressID`)
    REFERENCES `DoctorsNote`.`Address` (`addressID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `DoctorsNote`.`Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Patient` (
  `patientID` INT NOT NULL,
  `Nickname` VARCHAR(45) NULL,
  `Public Key` INT NOT NULL,
  `Failed Logins` INT NULL,
  `Username` VARCHAR(45) NULL,
  `personalInformationID` INT NOT NULL,
  `addressID` INT NOT NULL,
  PRIMARY KEY (`patientID`, `personalInformationID`, `addressID`),
  CONSTRAINT `fk_Patient_Personal Information1`
    FOREIGN KEY (`personalInformationID` , `addressID`)
    REFERENCES `DoctorsNote`.`Personal Information` (`personalInformationID` , `addressID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

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

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
