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
-- Table `DoctorsNote`.`Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Patient` (
  `patientID` INT(11) NOT NULL,
  `Nickname` VARCHAR(45) NULL DEFAULT NULL,
  `Public Key` INT(11) NOT NULL,
  `Failed Logins` INT(11) NULL DEFAULT NULL,
  `Username` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`patientID`))
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
    FOREIGN KEY (`patientID`)
    REFERENCES `DoctorsNote`.`Patient` (`patientID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
