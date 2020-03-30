<?php
require '../vendor/autoload.php';
use CoderCat\JWKToPEM\JWKConverter;

//Go back to login if logout button is pressed
if (isset($_POST['logout'])) {
    session_destroy();
    header("Location: https://doctorsnote.ddns.net/index.html");
}

//Config for cognito Client
//Call structure from: https://docs.aws.amazon.com/aws-sdk-php/v3/api/api-cognito-idp-2016-04-18.html#listusers
use Aws\CognitoIdentityProvider\CognitoIdentityProviderClient;

$client = CognitoIdentityProviderClient::factory(array(
    'region'  => 'us-east-2',
    'version'  => '2016-04-18'
));




//Config for MariaDatabase pdo
$host = 'doctorsnotedatabase.clqjrzlnojkj.us-east-2.rds.amazonaws.com';
$db = 'DoctorsNote';
$user = 'admin';
$pass = 'fh85KS*(98';
$charset = 'utf8';

$options = [
    \PDO::ATTR_ERRMODE            => \PDO::ERRMODE_EXCEPTION,
    \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_ASSOC,
    \PDO::ATTR_EMULATE_PREPARES   => false,
];

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";

try {
    $pdo = new \PDO($dsn, $user, $pass, $options);
} catch (\PDOException $e) {
    throw new \PDOException($e->getMessage(), (int)$e->getCode());
}
?>


<?php
//Redirect if not authenticated
session_start();
if ($_SESSION["status"] != "true") {
    header("Location: https://doctorsnote.ddns.net/index.html");
}


//Variables for Different ouputs
$pairingSuccess = false;
$doctorDoesntExist = false;
$patientDoesntExist = false;
$notUnique = false;
$foundDuplicate = false;
$pairingException = false;

$unpairingDoesntExist = false;
$unpairingSuccess = false;



//Pairing update logic
if (isset($_POST['submitPair'])) {
    $doctorIDinputPair = $_POST['doctorIDinputPair'];
    $patientIDinputPair = $_POST['patientIDinputPair'];


    try {
        if (isset($doctorIDinputPair) && trim($doctorIDinputPair) != ''
            && isset($patientIDinputPair) && trim($patientIDinputPair) != '') {

            //test to see if the doctor and patient exist in cognito
            $bothExist = true;
            //doctor
            $doctorToPair = $client->listUsers([
                //TODO: add role
                'AttributesToGet' => ['name', 'family_name', 'birthdate', 'custom:role'],
                'Filter' => "username = \"". $doctorIDinputPair . "\"", //Can only filter on certain default attributes
                'Limit' => 1,
                //'PaginationToken' => '<string>',
                'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
            ]);

            if (count($doctorToPair["Users"]) == 0 ||
                ($doctorToPair["Users"][0]["Attributes"][2]["Value"] != "doctor") && $doctorToPair["Users"][0]["Attributes"][2]["Value"] != "Doctor") {
                $doctorDoesntExist = true;

                $bothExist = false;
            }


            //patient
            $patientToPair = $client->listUsers([
                //TODO: add role
                'AttributesToGet' => ['name', 'family_name', 'birthdate', 'custom:role'],
                'Filter' => "username = \"". $patientIDinputPair . "\"", //Can only filter on certain default attributes
                'Limit' => 1,
                //'PaginationToken' => '<string>',
                'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
            ]);

            if (count($patientToPair["Users"]) == 0 ||
                ($patientToPair["Users"][0]["Attributes"][2]["Value"] != "patient" && $patientToPair["Users"][0]["Attributes"][2]["Value"] != "Patient")) {
                $patientDoesntExist = true;
                $bothExist = false;
            }


            //insert into database
            if ($patientIDinputPair == $doctorIDinputPair) {
                $notUnique = true;
            } else if ($bothExist) {
                /*====================Code for not allowing duplicats======================*/
                //$checkDuplicatesString = "SELECT * FROM conversationID WHERE userID = " . $patientIDinputPair;
                //$resultCheckDup = $pdo->query($checkDuplicatesString);
                //foreach ($resultCheckDup as $conversation) {

                //}
                $pairString = "SELECT conversationID FROM Conversation_has_User WHERE userID = \"" . $patientIDinputPair . "\";";
                $resultID = $pdo->query($pairString);
                $num = $resultID->rowCount();
                echo $num;
                $numFound = 0;
                $isDuplicate = 0;
                while ($each = $resultID->fetch()) {
                    foreach ($each as $convoID) {
                        $findPairString = "SELECT conversationID FROM Conversation_has_User WHERE userID = \"" . $doctorIDinputPair . "\" AND conversationID = " . $convoID . ";";
                        $matchedDoctor = $pdo->query($findPairString);
                        while($eachDoctorConvoID = $matchedDoctor->fetch()) {
                            echo $eachDoctorConvoID["conversationID"];
                            $isSupportGroupString = "SELECT * FROM Conversation_has_User WHERE conversationID = " . $eachDoctorConvoID["conversationID"] . ";";
                            $isSupportGroup = $pdo->query($isSupportGroupString);
                            if ($isSupportGroup->rowCount() == 2) {
                                //Found a duplicate that is not a support group
                                $isDuplicate = 1;
                            }
                        }

                        $numFound += $matchedDoctor->rowCount();
                        //echo $matchedDoctor->fetch()["conversationID"];


                    }
                }
                echo $numFound;

                if ($isDuplicate == 0) {
                    $pdo->query("INSERT INTO Conversation (status)
                            VALUES (0);");
                    $lastID = $pdo->lastInsertId();

                    //Add corresponding Conversation_has_User rows
                    $pdo->query("INSERT INTO Conversation_has_User (conversationID, userID)
                            VALUES (\"$lastID\", \"$doctorIDinputPair\");");
                    $pdo->query("INSERT INTO Conversation_has_User (conversationID, userID)
                            VALUES (\"$lastID\", \"$patientIDinputPair\");");


                    $pairingSuccess = true;
                } else {
                    $foundDuplicate = true;
                }
                //Create a new conversation in the database

            }
        }
    }
    catch (PDOException $e) {
        if ($e->errorInfo[1] == 1062) {
            $pairingException = true;
        } else {
            $pairingException = true;

        }
    }
}




//logic for unpairing submit
if (isset($_POST['submitUnpair'])) {
    $doctorIDinputUnpair = $_POST['doctorIDinputUnpair'];
    $patientIDinputUnpair = $_POST['patientIDinputUnpair'];


    //try {
    if (isset($doctorIDinputUnpair) && trim($doctorIDinputUnpair) != ''
        && isset($patientIDinputUnpair) && trim($patientIDinputUnpair) != '') {
        $unpairString = "SELECT conversationID FROM Conversation_has_User WHERE userID = \"" . $patientIDinputUnpair . "\";";
        $resultID = $pdo->query($unpairString);
        $num = $resultID->rowCount();
        while ($each = $resultID->fetch()) {
            foreach ($each as $convoID) {
                $findPairString = "SELECT conversationID FROM Conversation_has_User WHERE userID = \"" . $doctorIDinputUnpair . "\" AND conversationID = " . $convoID . ";";
                $matchedDoctor = $pdo->query($findPairString);
                //echo $matchedDoctor->fetch()["conversationID"];

                while ($LineToRemove = $matchedDoctor->fetch()) {
                    $idToRemove = $LineToRemove["conversationID"];
                    $isSupportGroupString = "SELECT * FROM Conversation_has_User WHERE conversationID = " . $idToRemove . ";";
                    $isSupportGroup = $pdo->query($isSupportGroupString);
                    if ($isSupportGroup->rowCount() <= 2) {
                        echo $idToRemove;
                        $stringRemovePair = "DELETE FROM Conversation_has_User WHERE conversationID = " . $idToRemove . ";";
                        $conversationRemoveString = "DELETE FROM Conversation WHERE conversationID = " . $idToRemove . ";";
                        $pdo->query($stringRemovePair);
                        $pdo->query($conversationRemoveString);
                    }
                }
            }
        }

        if ($num < 1) {
            $unpairingDoesntExist = true;
        }
        else {
            $unpairingSuccess = true;
        }
    }
    //}
    /*catch (PDOException $e) {
      if ($e->errorInfo[1] == 1062) {
        echo "<h4>Oops! Something went wrong, please try again.</h4>";
      } else {
        echo "<h4>Something went wrong, make sure both the doctor and patient exist.</h4>";
      }
    }*/
}
?>




<!doctype html>
<html lang="en">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Lobster+Two" type="text/css">
    <link rel="shortcut icon" href="https://awsmedia.s3.amazonaws.com/favicon.ico" type="image/ico" >
    <!--[if IE]><script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script><![endif]-->
    <link rel="stylesheet" href="/styles.css" type="text/css">


<title>DoctorsNote</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
<!--===============================================================================================-->
	<link rel="icon" type="image/png" href="images/icons/favicon.ico"/>
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/bootstrap/css/bootstrap.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="fonts/font-awesome-4.7.0/css/font-awesome.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/animate/animate.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/select2/select2.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/perfect-scrollbar/perfect-scrollbar.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="css/util.css">
	<link rel="stylesheet" type="text/css" href="css/main.css">
<!--===============================================================================================-->
</head>
<body>

<h1>DoctorsNote Web Portal</h1>

<div></div>
<h2>List of Patients</h2>
<div class="limiter">
		<div class="container-table100">
			<div class="wrap-table100">
				<div class="table100 ver1 m-b-110">
					<div class="table100-head">
						<table>
							<thead>
								<tr class="row100 head">
									<th class="cell100 column1">UserID</th>
									<th class="cell100 column2">Name</th>
									<th class="cell100 column3">Username</th>
									<th class="cell100 column4">Birth Date</th>
									<th class="cell100 column5">Gender</th>
								</tr>
							</thead>
						</table>
					</div>

					<div class="table100-body js-pscroll">
						<table>
							<tbody>
								<tr class="row100 body">

<?php




$resultPatient = $client->listUsers([
    'AttributesToGet' => ['name', 'family_name', 'birthdate', 'gender', 'custom:role'],
    'Filter' => "status = \"Enabled\"",
    //'Limit' => <integer>,
    //'PaginationToken' => '<string>',
    'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
]);


  foreach ($resultPatient["Users"] as $row) {
    if (sizeof($row["Attributes"]) == 5 && ($row["Attributes"][3]["Value"] == "patient" || $row["Attributes"][3]["Value"] == "Patient")) {

      echo "<tr class=\"row100 head\">
              <td class=\"cell100 column1\">". $row["Username"] ."</td>
              <td class=\"cell100 column2\">". $row["Attributes"][2]["Value"] ." ". $row["Attributes"][4]["Value"] ."</td>
              <td class=\"cell100 column3\"> - </td>
              <td class=\"cell100 column4\">". $row["Attributes"][0]["Value"] ."</td>
              <td class=\"cell100 column5\">". $row["Attributes"][1]["Value"] ."</td>
            </tr>";

    }
  }

?>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>

<h2>List of Doctors</h2>

<div class="limiter">
		<div class="container-table100">
			<div class="wrap-table100">
				<div class="table100 ver1 m-b-110">
					<div class="table100-head">
						<table>
							<thead>
								<tr class="row100 head">
									<th class="cell100 column1">Doctor ID</th>
									<th class="cell100 column2">Name</th>
									<th class="cell100 column3">System ID</th>
									<th class="cell100 column4">Location</th>
								</tr>
							</thead>
						</table>
					</div>

					<div class="table100-body js-pscroll">
						<table>
							<tbody>
								<tr class="row100 body">

<?php

$resultDoctor = $client->listUsers([
    'AttributesToGet' => ['name', 'family_name', 'email', 'address', 'middle_name', 'custom:role'], //TODO: fix these attributes. In particular, middle name should be replaced by the custom role
    'Filter' => "status = \"Enabled\"", //Can only filter on certain default attributes
    //'Limit' => <integer>,
    //'PaginationToken' => '<string>',
    'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
]);
  //if ($row["Attributes"][2]["Value"] != "Doctor") {
  foreach ($resultDoctor["Users"] as $row) {
    if (sizeof($row["Attributes"]) == 6 && ($row["Attributes"][3]["Value"] == "doctor" || $row["Attributes"][3]["Value"] == "Doctor")){
      echo "<tr class=\"row100 head\">
              <td class=\"cell100 column1\">". $row["Username"] ."</td>
              <td class=\"cell100 column2\">". $row["Attributes"][1]["Value"] ." ". $row["Attributes"][4]["Value"] ."</td>
              <td class=\"cell100 column3\">". $row["Attributes"][5]["Value"] ."</td>
              <td class=\"cell100 column4\">". $row["Attributes"][0]["Value"] ."</td>
            </tr>";
    }
  }
//}

?>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>



<h2>List of Doctor-Patient Pairings</h2>

<div class="limiter">
		<div class="container-table100">
			<div class="wrap-table100">
				<div class="table100 ver1 m-b-110">
					<div class="table100-head">
						<table>
							<thead>
								<tr class="row100 head">
									<th class="cell100 column1">Doctor ID</th>
									<th class="cell100 column2">Doctor Name</th>
									<th class="cell100 column3">Patient ID</th>
									<th class="cell100 column4">Patient Username</th>
                  <th class="cell100 column5">Patient Name</th>
									<th class="cell100 column6">Patient Birth Date</th>
								</tr>
							</thead>
						</table>
					</div>

					<div class="table100-body js-pscroll">
						<table>
							<tbody>
								<tr class="row100 body">

<?php



//Fetch all the conversationIDs from the database
$resultConvos = $pdo->query("SELECT conversationID FROM DoctorsNote.Conversation");
//echo $resultConvos->rowCount();

  //echo $resultPair->rowCount() + 2;

  //for each conversationID, get the two userIDs if they exist
  while($each = $resultConvos->fetch()) {
      foreach($each as $convoID) {
          //echo $convoID . "\n";
          $queryString = "SELECT UserID FROM Conversation_has_User WHERE conversationID = ";
          $queryString .= $convoID;
          $resultPair = $pdo->query($queryString);

          if ($resultPair->rowCount() == 2) {
              $users = $resultPair->fetchAll();
              $doctor = "-";
              $patient = "-";
              $doctorAttr = "-";
              $patientAttr = "-";
              $howManyExist = 0;
              //Find which one is the doctor and which one is the patient
              foreach($users as $user) {
                  //echo $user["UserID"] . "\n";
                  $resultCognitoUser = $client->listUsers([
                      'AttributesToGet' => ['name', 'family_name', 'birthdate', 'custom:role'],
                      'Filter' => "username = \"". $user["UserID"] . "\"",
                      'Limit' => 1,
                      'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
                  ]);

                  //echo $resultCognitoUser . "\n";
                  if (sizeof($resultCognitoUser["Users"]) == 1) {
                      $howManyExist++;
                      $userAttr = $resultCognitoUser["Users"][0]["Attributes"];
                      if ($userAttr[2]["Value"] == "doctor" || $userAttr[2]["Value"] == "Doctor") {
                          $doctor = $user;
                          $cognitoDoctor = $resultCognitoUser;
                          $doctorAttr = $userAttr;
                      } else {
                          $patient = $user;
                          $cognitoPatient = $resultCognitoUser;
                          $patientAttr = $userAttr;
                      }
                  }
              }
              if ($howManyExist == 2) {
                  echo "<tr class=\"row100 head\">
                          <td class=\"cell100 column1\">" . $doctor["UserID"] . "</td>
                          <td class=\"cell100 column2\">" . $doctorAttr[1]["Value"] . " " . $doctorAttr[3]["Value"] . "</td>
                          <td class=\"cell100 column3\">" . $patient["UserID"] . "</td>
                          <td class=\"cell100 column4\">" . "</td>
                          <td class=\"cell100 column5\">" . $patientAttr[1]["Value"] . " " . $patientAttr[3]["Value"] . "</td>
                          <td class=\"cell100 column6\">" . $patientAttr[0]["Value"] . "</td>
                        </tr>";
              }
          }
      }
      echo "<div/>";
  }



/*

  while ($row = $resultPair-> fetch()) {
    //get the doctor info from cognito
    $resultDoctor = $client->listUsers([
      'AttributesToGet' => ['name', 'family_name'],
      'Filter' => "username = \"". $row["doctorID"] . "\"", //Can only filter on certain default attributes
      'Limit' => 1,
      //'PaginationToken' => '<string>',
      'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
      ]);

    // echo $resultDoctor . "\n"; //testing


     //get the patient info from cognito
     $resultPatient = $client->listUsers([
      'AttributesToGet' => ['name', 'family_name', 'birthdate'],
      'Filter' => "username = \"". $row["patientID"] . "\"", //Can only filter on certain default attributes
      'Limit' => 1,
      //'PaginationToken' => '<string>',
      'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
     ]);


     if (sizeof($resultPatient["Users"]) >= 1 && sizeof($resultDoctor["Users"]) >= 1) {

       $DoctorAttr = $resultDoctor["Users"][0]["Attributes"];
       $PatientAttr = $resultPatient["Users"][0]["Attributes"];

       if (sizeof($DoctorAttr) == 2 && sizeof($PatientAttr) == 3) {

      echo "<tr class=\"row100 head\">
              <td class=\"cell100 column1\">". $row["doctorID"] ."</td>
                <td class=\"cell100 column2\">". $DoctorAttr[0]["Value"] ." ". $DoctorAttr[1]["Value"]  ."</td>
                <td class=\"cell100 column3\">". $row["patientID"] ."</td>
                <td class=\"cell100 column4\">"."</td>
                <td class=\"cell100 column5\">". $PatientAttr[1]["Value"] ." ". $PatientAttr[2]["Value"]  ."</td>
                <td class=\"cell100 column6\">". $PatientAttr[0]["Value"] ."</td>
            </tr>";
       }
     }
  }

*/

?>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>

<?php
  echo "<h2>Insert Doctor ID and Patient ID for Pairing</h2>";
  echo "<br>";
  echo "<form class='form' method='post'>";
  echo "<label for='doctorIDinputPair' class='labelNice'>Doctor ID:</label>
        <input class='input' name='doctorIDinputPair'/>";
  echo "<label for='patientIDinputPair' class = 'labelNice'>Patient ID:</label>
        <input class='input' name='patientIDinputPair'/>";
  //echo "<br />";
  echo "<input class='submit' type='submit' name='submitPair' value='update' />";
  echo "</form> <br>";

  if ($doctorDoesntExist) {
      echo "<h4>Pairing unsuccessful, make sure the doctor exists.</h4>";
  }
  if ($patientDoesntExist) {
      echo "<h4>Pairing unsuccessful, make sure the patient exists.</h4>";
  }
  if ($notUnique) {
      echo "<h4>Doctor ID and Patient ID must be unique!</h4>";
  }
  if ($pairingSuccess) {
      echo "<h4>Successfully Updated!</h4>";
  }
  if ($foundDuplicate) {
      echo "<h4>Cannot insert duplicate Doctor-Patient Pairing!</h4>";
  }
  if ($pairingException) {
      echo "<h4>Something went wrong, make sure both the doctor and patient exist.</h4>";
  }


?>

<br />

<?php
  echo "<h2>Insert Doctor ID and Patient ID for Un-Pairing</h2>";
  echo "<br>";
  echo "<form class='form' method='post'>";
  echo "<label for='doctorIDinputUnpair' class='labelNice'>Doctor ID:</label>
        <input class='input' name='doctorIDinputUnpair'/>";
  echo "<label for='patientIDinputUnpair' class = 'labelNice'>Patient ID:</label>
        <input class='input' name='patientIDinputUnpair'/>";
  //echo "<br />";
  echo "<input class='submit' type='submit' name='submitUnpair' value='update' />";
  echo "</form> <br>";

  if ($unpairingDoesntExist) {
      echo "<h4>Doctor-Patient pairing doesn't exist!</h4>";
  }
  if ($unpairingSuccess) {
      echo "<h4>Success!</h4>";
  }


  echo "<br/>
   <h5>Please </h5>";
  echo "<form class='form' method='post' onsubmit='setTimeout(window.location.reload, 200)'>";
echo "<input class='submit' type='submit' name='logout' value='logout' onclick='window.location.reload() '/>";
echo "</form>";
  echo "<h5>before you leave the page</h5>";
?>
<br>

<!--===============================================================================================-->
	<script src="vendor/jquery/jquery-3.2.1.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/bootstrap/js/popper.js"></script>
	<script src="vendor/bootstrap/js/bootstrap.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/select2/select2.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/perfect-scrollbar/perfect-scrollbar.min.js"></script>
	<script>
		$('.js-pscroll').each(function(){
			var ps = new PerfectScrollbar(this);

			$(window).on('resize', function(){
				ps.update();
			})
		});


	</script>
<!--===============================================================================================-->
	<script src="js/main.js"></script>



    <!--[if lt IE 9]><script src="http://css3-mediaqueries-js.googlecode.com/svn/trunk/css3-mediaqueries.js"></script><![endif]-->

</body>
</html>
<?
//}
?>
