<?php
require '../vendor/autoload.php';
//use CoderCat\JWKToPEM\JWKConverter;

//Redirect if not authenticated
session_start();
if ($_SESSION["status"] != "true") {
    header("Location: https://doctorsnote.ddns.net/index.html");
}

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



//Variables for Different ouputs
$pairingSuccess = false;
$doctorDoesntExist = false;
$patientDoesntExist = false;
$notUnique = false;
$foundDuplicate = false;
$pairingException = false;

$unpairingDoesntExist = false;
$unpairingSuccess = false;
$unpairingException = false;

$cognitoException = false;


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
            try {
                $doctorToPair = $client->listUsers([
                    //TODO: add role
                    'AttributesToGet' => ['name', 'family_name', 'birthdate', 'custom:role'],
                    'Filter' => "username = \"" . $doctorIDinputPair . "\"", //Can only filter on certain default attributes
                    'Limit' => 1,
                    //'PaginationToken' => '<string>',
                    'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
                ]);
            } catch (Aws\CognitoIdentityProvider\Exception\CognitoIdentityProviderException $cognitoIdentityProviderException) {
                $cognitoException = true;
            }

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
                $resultID = $pdo->prepare('SELECT conversationID FROM Conversation_has_User WHERE userID = ?;');
                $resultID->execute(array($patientIDinputPair));
                //$pairString = "SELECT conversationID FROM Conversation_has_User WHERE userID = \"" . $patientIDinputPair . "\";";
                //$resultID = $pdo->query($pairString);
                $num = $resultID->rowCount();
                //echo $num;
                $numFound = 0;
                $isDuplicate = 0;
                while ($each = $resultID->fetch()) {
                    foreach ($each as $convoID) {
                        $matchedDoctor = $pdo->prepare('SELECT conversationID FROM Conversation_has_User WHERE userID = ? AND conversationID = ?');
                        $matchedDoctor->execute(array($doctorIDinputPair, $convoID));
                        //$findPairString = "SELECT conversationID FROM Conversation_has_User WHERE userID = \"" . $doctorIDinputPair . "\" AND conversationID = " . $convoID . ";";
                        //$matchedDoctor = $pdo->query($findPairString);
                        $isSupportGroup = $pdo->prepare('SELECT * FROM Conversation_has_User WHERE conversationID = ?;');
                        while($eachDoctorConvoID = $matchedDoctor->fetch()) {
                            //echo $eachDoctorConvoID["conversationID"];
                            $isSupportGroup->execute(array($eachDoctorConvoID["conversationID"]));
                            //$isSupportGroupString = "SELECT * FROM Conversation_has_User WHERE conversationID = " . $eachDoctorConvoID["conversationID"] . ";";
                            //$isSupportGroup = $pdo->query($isSupportGroupString);
                            if ($isSupportGroup->rowCount() == 2) {
                                //Found a duplicate that is not a support group
                                $isDuplicate = 1;
                            }
                        }

                        //$numFound += $matchedDoctor->rowCount();
                        //echo $matchedDoctor->fetch()["conversationID"];


                    }
                }
                //echo $numFound;

                if ($isDuplicate == 0) {
                    $pdo->query("INSERT INTO Conversation (status, adminPublicKey)
                            VALUES (0, \"MIIBCgKCAQEA3EuLDvxNqAF3bRqwlxEAsfcGLg/LnVWJxB/fmBOyZVbKWF8klgScF5aw1irj3NwJw810Xp3ZZOhOUHxW6jw85XIoCdwmwzGPEHbbvwXNsW/uP5pSv3GZa1RuiLP8XjUZ2uzGK3mjHMrAlPn5hhYntp730C/1tyYOJgr3eWzLH7lWcHpR2cv06JOoVrwuk67ggXgNlNy0nY0dPmar+OEKd911JDcWbS77BZ5CkT8WeKG9I2SwFNH1KdnEbbGQLe3iZRUrWxYbRg0EQsE9gpML14R3ee9YjRlh1Y/Z904bEaD5vhy+/DwjdAag1C+0BtGiYNpJ/wbjFEKgqFKVD1V/bwIDAQAB\");");
                    $lastID = $pdo->lastInsertId();

                    //Add corresponding Conversation_has_User rows
                    $temp = $pdo->prepare('INSERT INTO Conversation_has_User (conversationID, userID)
                            VALUES (?, ?);');
                    $temp->execute(array($lastID, $doctorIDinputPair));
                    $temp->execute(array($lastID, $patientIDinputPair));
                    //$pdo->query("INSERT INTO Conversation_has_User (conversationID, userID)
                    //        VALUES (\"$lastID\", \"$doctorIDinputPair\");");
                    //$pdo->query("INSERT INTO Conversation_has_User (conversationID, userID)
                    //        VALUES (\"$lastID\", \"$patientIDinputPair\");");


                    $pairingSuccess = true;
                } else {
                    $foundDuplicate = true;
                }
                //Create a new conversation in the database

            }
        }
    }
    catch (Exception $e) {
        $pairingException = true;
    }
}




//logic for unpairing submit
if (isset($_POST['submitUnpair'])) {
    $doctorIDinputUnpair = $_POST['doctorIDinputUnpair'];
    $patientIDinputUnpair = $_POST['patientIDinputUnpair'];


    try {
        if (isset($doctorIDinputUnpair) && trim($doctorIDinputUnpair) != ''
            && isset($patientIDinputUnpair) && trim($patientIDinputUnpair) != '') {
            $resultID = $pdo->prepare('SELECT conversationID FROM Conversation_has_User WHERE userID =  ? ;');
            $resultID->execute(array($patientIDinputUnpair));
            //$unpairString = "SELECT conversationID FROM Conversation_has_User WHERE userID = \"" . $patientIDinputUnpair . "\";";
            //$resultID = $pdo->query($unpairString);
            $num = $resultID->rowCount();
            //echo $num;
            while ($each = $resultID->fetch()) {
                foreach ($each as $convoID) {
                    $matchedDoctor = $pdo->prepare('SELECT conversationID FROM Conversation_has_User WHERE userID = ? AND conversationID = ?;');
                    $matchedDoctor->execute(array($doctorIDinputUnpair, $convoID));
                    //$findPairString = "SELECT conversationID FROM Conversation_has_User WHERE userID = \"" . $doctorIDinputUnpair . "\" AND conversationID = " . $convoID . ";";
                    //$matchedDoctor = $pdo->query($findPairString);
                    //echo $matchedDoctor->fetch()["conversationID"];


                    while ($LineToRemove = $matchedDoctor->fetch()) {
                        $idToRemove = $LineToRemove["conversationID"];
                        $isSupportGroup = $pdo->prepare('SELECT * FROM Conversation_has_User WHERE conversationID = ?;');
                        $isSupportGroup->execute(array($idToRemove));
                        //$isSupportGroupString = "SELECT * FROM Conversation_has_User WHERE conversationID = " . $idToRemove . ";";
                        //$isSupportGroup = $pdo->query($isSupportGroupString);
                        if ($isSupportGroup->rowCount() <= 2) {
                            //echo $idToRemove;
                            $temp = $pdo->prepare('DELETE FROM Conversation_has_User WHERE conversationID = ?;');
                            $temp->execute(array($idToRemove));
                            $temp = $pdo->prepare('DELETE FROM Conversation WHERE conversationID = ?;');
                            $temp->execute(array($idToRemove));
                            //$stringRemovePair = "DELETE FROM Conversation_has_User WHERE conversationID = " . $idToRemove . ";";
                            //$conversationRemoveString = "DELETE FROM Conversation WHERE conversationID = " . $idToRemove . ";";
                            //$pdo->query($stringRemovePair);
                            //$pdo->query($conversationRemoveString);
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
    }
    catch (Exception $e) {
        $unpairingException = true;
    }
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

<div class="header">
    <a href="https://doctorsnote.ddns.net/homepage/index.php" class="logo">DoctorsNote</a>
    <div class="header-right">
        <a class="active" href="https://doctorsnote.ddns.net/homepage/index.php">Home</a>
        <!TODO: alter href to be online!>
        <a href="https://doctorsnote.ddns.net/homepage/accountManagement.php">Account Management</a>
        <a href="http://localhost/WebsiteFiles/homepage/transcripts.php">Transcripts</a>
    </div>
</div>


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
									<!--<th class="cell100 column3">Username</th>-->
									<th class="cell100 column3">Birth Date</th>
									<th class="cell100 column4">Gender</th>
								</tr>
							</thead>
						</table>
					</div>

					<div class="table100-body js-pscroll">
						<table>
							<tbody>
								<tr class="row100 body">

<?php



try {
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
              <td class=\"cell100 column3\">". $row["Attributes"][0]["Value"] ."</td>
              <td class=\"cell100 column4\">". $row["Attributes"][1]["Value"] ."</td>
            </tr>";

    }
  }
} catch (Aws\CognitoIdentityProvider\Exception\CognitoIdentityProviderException $cognitoIdentityProviderException) {
    echo "<h4>Error! Cognito user detected with incomplete info. Please contact the Developers.</h4>";
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

try {
    $resultDoctor = $client->listUsers([
        'AttributesToGet' => ['name', 'family_name', 'email', 'address', 'middle_name', 'custom:role'], //TODO: fix these attributes. In particular, middle name should be replaced by the custom role
        'Filter' => "status = \"Enabled\"", //Can only filter on certain default attributes
        //'Limit' => <integer>,
        //'PaginationToken' => '<string>',
        'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
    ]);
    //if ($row["Attributes"][2]["Value"] != "Doctor") {
    foreach ($resultDoctor["Users"] as $row) {
        if (sizeof($row["Attributes"]) == 6 && ($row["Attributes"][3]["Value"] == "doctor" || $row["Attributes"][3]["Value"] == "Doctor")) {
            echo "<tr class=\"row100 head\">
              <td class=\"cell100 column1\">" . $row["Username"] . "</td>
              <td class=\"cell100 column2\">" . $row["Attributes"][1]["Value"] . " " . $row["Attributes"][4]["Value"] . "</td>
              <td class=\"cell100 column3\">" . $row["Attributes"][5]["Value"] . "</td>
              <td class=\"cell100 column4\">" . $row["Attributes"][0]["Value"] . "</td>
            </tr>";
        }
    }

} catch (Aws\CognitoIdentityProvider\Exception\CognitoIdentityProviderException $cognitoIdentityProviderException) {
    echo "<h4>Error! Cognito user detected with incomplete info. Please contact the Developers.</h4>";
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
									<!--<th class="cell100 column4">Patient Username</th>-->
                  <th class="cell100 column4">Patient Name</th>
									<th class="cell100 column5">Patient Birth Date</th>
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
          //echo $convoID . "\n
          $resultPair = $pdo->prepare('SELECT UserID FROM Conversation_has_User WHERE conversationID = ?');
          $resultPair->execute(array($convoID));

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
                          <td class=\"cell100 column4\">" . $patientAttr[1]["Value"] . " " . $patientAttr[3]["Value"] . "</td>
                          <td class=\"cell100 column5\">" . $patientAttr[0]["Value"] . "</td>
                        </tr>";
              }
          }
      }
      echo "<div/>";
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


<div class="row">
    <div class="column">
  <h2>Doctor-Patient Pairing</h2>
  <br>
  <form class='form' method='post'>
  <label for='doctorIDinputPair' class='labelNice'>Doctor ID:</label>
        <input class='input' name='doctorIDinputPair'/>
  <label for='patientIDinputPair' class = 'labelNice'>Patient ID:</label>
        <input class='input' name='patientIDinputPair'/>
  <input class='submit' type='submit' name='submitPair' value='update' />
  </form> <br>

<?php

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


<br/>
    </div>

    <div class="column">


        <h2>Doctor-Patient Unpairing</h2>
        <br>
        <form class='form' method='post'>
        <label for='doctorIDinputUnpair' class='labelNice'>Doctor ID:</label>
        <input class='input' name='doctorIDinputUnpair'/>

        <label for='patientIDinputUnpair' class = 'labelNice'>Patient ID:</label>
        <input class='input' name='patientIDinputUnpair'/>

        <input class='submit' type='submit' name='submitUnpair' value='update' />
        </form>
        <br>

<?php

  if ($unpairingException) {
      echo "<h4>Error with ID formatting, un-pairing failed</h4>";
  }
  else if ($unpairingDoesntExist) {
      echo "<h4>Doctor-Patient pairing doesn't exist!</h4>";
  }
  else if ($unpairingSuccess) {
      echo "<h4>Success!</h4>";
  }

?>
    </div>
</div>

<div>
    <br/>
    <h5>Please </h5>
    <form class='form' method='post' onsubmit='setTimeout(window.location.reload, 200)'>
    <input class='submit' type='submit' name='logout' value='logout' onclick='window.location.reload() '/>
    </form>
    <h5>before you leave the page</h5>
    <br>
</div>

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
