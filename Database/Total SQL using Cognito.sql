-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema DoctorsNote
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `DoctorsNote` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;
USE `DoctorsNote` ;

-- -----------------------------------------------------
-- Table `DoctorsNoteTest`.`Conversation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Conversation` (
  `conversationID` INT(11) NOT NULL AUTO_INCREMENT,
  `conversationName` VARCHAR(45) NULL DEFAULT NULL,
  `lastMessageTime` DATETIME(3) NULL DEFAULT NULL,
  `status` TINYINT(4) NULL DEFAULT NULL,
  `isSupportGroup` TINYINT NULL DEFAULT 0,
  PRIMARY KEY (`conversationID`))
ENGINE = InnoDB
AUTO_INCREMENT = 15
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Conversation_has_User`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Conversation_has_User` (
  `conversationID` INT(11) NOT NULL,
  `userID` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`conversationID`, `userID`),
  CONSTRAINT `fk_Conversation_has_User_Conversation1`
    FOREIGN KEY (`conversationID`)
    REFERENCES `DoctorsNote`.`Conversation` (`conversationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Doctor_has_Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Doctor_has_Patient` (
  `doctorID` VARCHAR(36) NOT NULL,
  `patientID` VARCHAR(36) NOT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Message`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Message` (
  `messageID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `content` LONGTEXT NULL DEFAULT NULL,
  `sender` VARCHAR(36) NOT NULL,
  `recipient` VARCHAR(36) NOT NULL,
  `timeCreated` DATETIME(3) NULL DEFAULT CURRENT_TIMESTAMP(),
  `conversationID` INT(11) NOT NULL,
  PRIMARY KEY (`messageID`, `conversationID`),
  CONSTRAINT `fk_Message_Conversation1`
    FOREIGN KEY (`conversationID`)
    REFERENCES `DoctorsNote`.`Conversation` (`conversationID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 10
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;

-- -----------------------------------------------------
-- Table `DoctorsNote`.`Reminder`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Reminder` (
  `reminderID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `content` LONGTEXT NULL DEFAULT NULL,
  `remindedID` VARCHAR(36) NOT NULL,
  `creatorID` VARCHAR(36) NOT NULL,
  `timeCreated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `alertTime` DATETIME NOT NULL,
  PRIMARY KEY (`reminderID`))
ENGINE = InnoDB
AUTO_INCREMENT = 20
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
