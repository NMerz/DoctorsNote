-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema DoctorsNote
-- -----------------------------------------------------
-- Schema for CS307 Project;
-- Team 07;
-- DoctorsNote;
-- 2/13/2020
-- 

-- -----------------------------------------------------
-- Schema DoctorsNote
--
-- Schema for CS307 Project;
-- Team 07;
-- DoctorsNote;
-- 2/13/2020
-- 
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `DoctorsNote` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;
USE `DoctorsNote` ;

-- -----------------------------------------------------
-- Table `DoctorsNote`.`Message`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Message` (
  `idMessage` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `text` LONGTEXT NULL,
  `createdTime` DATETIME(1),
  `sender` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`idMessage`),
  UNIQUE INDEX `idMessage_UNIQUE` (`idMessage` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Conversation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Conversation` (
  `idConversation` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `recipient` INT UNSIGNED NOT NULL,
  `Message_idMessage` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`idConversation`),
  CONSTRAINT `fk_Conversation_Message`
    FOREIGN KEY (`Message_idMessage`)
    REFERENCES `DoctorsNote`.`Message` (`idMessage`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`SupportGroup`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`SupportGroup` (
  `idSupportGroup` INT NOT NULL AUTO_INCREMENT,
  `members` INT UNSIGNED NOT NULL,
  `admin` INT UNSIGNED NOT NULL,
  `Message_idMessage` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`idSupportGroup`),
  CONSTRAINT `fk_SupportGroup_Message1`
    FOREIGN KEY (`Message_idMessage`)
    REFERENCES `DoctorsNote`.`Message` (`idMessage`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
