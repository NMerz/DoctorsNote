-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

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
  `idConversation` INT(11) NOT NULL,
  `ConversationName` VARCHAR(45) NULL,
  `lastMessageTime` DATETIME NULL,
  `status` TINYINT NULL,
  PRIMARY KEY (`idConversation`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Message`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Message` (
  `idMessage` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `text` LONGTEXT NULL,
  `sender` INT(10) UNSIGNED NOT NULL,
  `timeCreated` DATETIME NULL,
  `recipient` INT(10) UNSIGNED NOT NULL,
  `Conversation_idConversation` INT(11) NOT NULL,
  PRIMARY KEY (`idMessage`, `Conversation_idConversation`),
  CONSTRAINT `fk_Message_Conversation`
    FOREIGN KEY (`Conversation_idConversation`)
    REFERENCES `DoctorsNote`.`Conversation` (`idConversation`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`SupportGroup`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`SupportGroup` (
  `idSupportGroup` INT(11) NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(45) NULL,
  PRIMARY KEY (`idSupportGroup`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
