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
USE `DoctorsNote` ;

-- -----------------------------------------------------
-- Table `DoctorsNote`.`Address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Address` (
  `idAddress` INT NOT NULL,
  `Street1` VARCHAR(45) NULL,
  `Street2` VARCHAR(45) NULL,
  `City` VARCHAR(45) NULL,
  `State` VARCHAR(2) NULL COMMENT 'State code of two letters e.g. OH\n\nMight need to change this for foreign countries.',
  `Country` VARCHAR(45) NULL,
  `PostalCode` INT NULL,
  PRIMARY KEY (`idAddress`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Personal Information`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Personal Information` (
  `idPersonal Information` INT NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Birth Date` DATE NULL,
  `Sex` VARCHAR(10) NULL,
  `Phone Number` INT(11) NULL,
  `Address_idAddress` INT NOT NULL,
  PRIMARY KEY (`idPersonal Information`, `Address_idAddress`),
  CONSTRAINT `fk_Personal Information_Address1`
    FOREIGN KEY (`Address_idAddress`)
    REFERENCES `DoctorsNote`.`Address` (`idAddress`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `DoctorsNote`.`Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Patient` (
  `idPatient` INT NOT NULL,
  `Nickname` VARCHAR(45) NULL,
  `Public Key` INT NOT NULL,
  `Failed Logins` INT NULL,
  `Username` VARCHAR(45) NULL,
  `Personal Information_idPersonal Information` INT NOT NULL,
  `Personal Information_Address_idAddress` INT NOT NULL,
  PRIMARY KEY (`idPatient`, `Personal Information_idPersonal Information`, `Personal Information_Address_idAddress`),
  CONSTRAINT `fk_Patient_Personal Information1`
    FOREIGN KEY (`Personal Information_idPersonal Information` , `Personal Information_Address_idAddress`)
    REFERENCES `DoctorsNote`.`Personal Information` (`idPersonal Information` , `Address_idAddress`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
