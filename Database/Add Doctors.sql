-- -----------------------------------------------------
-- Table `DoctorsNote`.`Doctor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Doctor` (
  `doctorID` INT NOT NULL AUTO_INCREMENT,
  `systemID` INT NULL,
  `Name` VARCHAR(45) NULL,
  `Location` VARCHAR(45) NULL,
  PRIMARY KEY (`doctorID`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `DoctorsNote`.`Doctor_has_Patient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `DoctorsNote`.`Doctor_has_Patient` (
  `doctorID` INT NOT NULL,
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
ENGINE = InnoDB;
