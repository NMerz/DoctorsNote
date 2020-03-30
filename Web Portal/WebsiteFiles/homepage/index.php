<?php
require '../vendor/autoload.php';
use CoderCat\JWKToPEM\JWKConverter;

//$jwkConverter = new JWKConverter();

//$jwtsText = file_get_contents("https://cognito-idp.us-east-2.amazonaws.com/us-east-2_6dVeCsyh2/.well-known/jwks.json");
//echo $jwtsText;

//$jwts = json_decode($jwtsText, true);
//echo $jwts["keys"][0];

//Get the public key

//$PEM = $jwkConverter->toPEM($jwts["keys"][0]);
//echo $PEM;

?>


<?php

/*$_POST https://doctorsnote.auth.us-east-2.amazoncognito.com/oauth2/token >
Content-Type='application/x-www-form-urlencoded'&
Authorization=Basic aSdxd892iujendek328uedj

grant_type=client_credentials&
scope={resourceServerIdentifier1}/{scope1} {resourceServerIdentifier2}/{scope2}
*/

//$_POST["code"];

///oauth2/authorize?response_type=code&client_id=********&redirect_uri=https://www.amazon.com
///
/// http://localhost/WebsiteFiles/homepage/index.php#id_token=eyJraWQiOiJKUnlya2RVOUZ1ZHRJT2ZYMk5UbHd6SFJ1ejdMVlFcL2ZsUDZtS3liSVVBVT0iLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoiNEdtYVZuWFp3NlpreXpYbGZIazhJdyIsInN1YiI6IjQxYmNiNjA2LWVjZTgtNDA2NC1hYzBiLTNmN2JjMmU3ZjdiNSIsImF1ZCI6IjUzOG8yOXQ3NGZnM20ydGs2MGNpYXNibXM0IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImV2ZW50X2lkIjoiNGM4ZmNmMmItNWZhZC00MGZjLTg4MDUtNjYxMTM1OWRjZTE0IiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE1ODUyNzE1MzYsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTIuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0yXzZkVmVDc3loMiIsImNvZ25pdG86dXNlcm5hbWUiOiJzbWl0aDIyIiwiZXhwIjoxNTg1Mjc1MTM2LCJpYXQiOjE1ODUyNzE1MzYsImVtYWlsIjoic21pdDMwMTlAcHVyZHVlLmVkdSJ9.wuL-A1GXXbmEmmoTswOeZWIJmJxmy-gwdnbGxWtUUWN20JBwxNhQsup5MIvRdJwUCScWXafKz6995xelePvZzY0WB-eHW6PSQKCiCsOvXYS16Hvc_iqVcQqTwH5Mi1RSXwLHTVdFeOjMgOGFA3iVK3rbAag2pyUyBwfffq1-poylpL_MC85m8RgGF6lnAn7JoWQA0vxaiCWjWVkx02uTepi74ybzCZvs59YEhANJHu7UHAjegD65FbC1kr7ugtBnQNlolztwddItEfaWFnG3cxgLkRFJxn85SfWZlJ3aSqBsX3Oeaa7wy481HLY7MhKlr8RK-hwuyjaIZXuqQavWtQ&access_token=eyJraWQiOiJUQ2k4KzAzWHpybnNxRmQxRmRBeGRGTTZ0RTlFRlRUZ1ZjR2xBeHUwdEVBPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0MWJjYjYwNi1lY2U4LTQwNjQtYWMwYi0zZjdiYzJlN2Y3YjUiLCJldmVudF9pZCI6IjRjOGZjZjJiLTVmYWQtNDBmYy04ODA1LTY2MTEzNTlkY2UxNCIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoiYXdzLmNvZ25pdG8uc2lnbmluLnVzZXIuYWRtaW4gcGhvbmUgb3BlbmlkIHByb2ZpbGUgZW1haWwiLCJhdXRoX3RpbWUiOjE1ODUyNzE1MzYsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy1lYXN0LTIuYW1hem9uYXdzLmNvbVwvdXMtZWFzdC0yXzZkVmVDc3loMiIsImV4cCI6MTU4NTI3NTEzNiwiaWF0IjoxNTg1MjcxNTM2LCJ2ZXJzaW9uIjoyLCJqdGkiOiJkODU0OGExZC04ZDQyLTQxOTMtODdmMi03YjkxNDBkMjcxNjkiLCJjbGllbnRfaWQiOiI1MzhvMjl0NzRmZzNtMnRrNjBjaWFzYm1zNCIsInVzZXJuYW1lIjoic21pdGgyMiJ9.MM7VDBQ1NqX8nd98ZQRRh5JpCGnS2bwtsQQeuaQyUGrzHl80YUyDmcnuAgAGXCQZZp2_lt0X4UZWouml52osJUNOaYb198LVezky09DpigiAbTg5MlbKYC7JWjO1NPIxFGHl7SBUH02Va-EdOfWaZ5nD-C2XwLyBswy8m02hTrBXrMr1GnknVy803n3bot3F61vzY5LI8uRihdtnFmC94T5OnEGEDSuJhNTC7keSrBL3-_weH-cfC1T3ffXbi4giwPJ7WiGy1ilD8trm360l4pa5xKQOf6mQsR49x9cubmVPq5p9pG1aIOywgGzcArk9ZZTlHPpKsJjyPy9j0X3Mdg&expires_in=3600&token_type=Bearer
///

//echo $_SERVER['PHP_SELF'];
//echo $_SERVER['REQUEST_URI'];
//echo "\n" . $_SERVER['QUERY_STRING'] . "\n";
//echo $_GET['id_token'];
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


//Call structure from: https://docs.aws.amazon.com/aws-sdk-php/v3/api/api-cognito-idp-2016-04-18.html#listusers
use Aws\CognitoIdentityProvider\CognitoIdentityProviderClient;

$client = CognitoIdentityProviderClient::factory(array(
    'region'  => 'us-east-2',
    'version'  => '2016-04-18'
));

$resultPatient = $client->listUsers([
    'AttributesToGet' => ['name', 'family_name', 'birthdate', 'gender', 'custom:role'],
    'Filter' => "status = \"Enabled\"",
    //'Limit' => <integer>,
    //'PaginationToken' => '<string>',
    'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
]);


  foreach ($resultPatient["Users"] as $row) {
    if (sizeof($row["Attributes"]) == 5 && $row["Attributes"][3]["Value"] == "patient") {

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
    if (sizeof($row["Attributes"]) == 6 && $row["Attributes"][3]["Value"] == "doctor") {
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
                      if ($userAttr[2]["Value"] == "doctor") {
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
          'AttributesToGet' => ['name', 'family_name', 'birthdate'],
          'Filter' => "username = \"". $doctorIDinputPair . "\"", //Can only filter on certain default attributes
          'Limit' => 1,
          //'PaginationToken' => '<string>',
          'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
         ]);

         if (count($doctorToPair["Users"]) == 0) {
           echo "<h4>Pairing unsuccessful, make sure the doctor exists.</h4>";
           $bothExist = false;
         }


       //patient
         $patientToPair = $client->listUsers([
                 //TODO: add role
          'AttributesToGet' => ['name', 'family_name', 'birthdate'],
          'Filter' => "username = \"". $patientIDinputPair . "\"", //Can only filter on certain default attributes
          'Limit' => 1,
          //'PaginationToken' => '<string>',
          'UserPoolId' => 'us-east-2_Cobrg1kBn', // REQUIRED
         ]);

         if (count($patientToPair["Users"]) == 0) {
           echo "<h4>Pairing unsuccessful, make sure the patient exists.</h4>";
           $bothExist = false;
         }


       //insert into database
          if ($patientIDinputPair == $doctorIDinputPair) {
              echo "<h4>Doctor ID and Patient ID must be unique!</h4>";
          } else if ($bothExist) {
              /*====================Code for not allowing duplicats======================*/
              //$checkDuplicatesString = "SELECT * FROM conversationID WHERE userID = " . $patientIDinputPair;
              //$resultCheckDup = $pdo->query($checkDuplicatesString);
              //foreach ($resultCheckDup as $conversation) {

              //}

             //Create a new conversation in the database
           $pdo->query("INSERT INTO Conversation (status)
                        VALUES (0);");
             $lastID = $pdo->lastInsertId();

           //Add corresponding Conversation_has_User rows
             $pdo->query("INSERT INTO Conversation_has_User (conversationID, userID)
                        VALUES (\"$lastID\", \"$doctorIDinputPair\");");
             $pdo->query("INSERT INTO Conversation_has_User (conversationID, userID)
                        VALUES (\"$lastID\", \"$patientIDinputPair\");");


           echo "<h4>Successfully Updated!</h4>";
         }
      }
    }
    catch (PDOException $e) {
      if ($e->errorInfo[1] == 1062) {
        echo "<h4>Pairing already exists!</h4>";
      } else {
        echo "<h4>Something went wrong, make sure both the doctor and patient exist.</h4>";
      }
    }
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
                          echo $idToRemove;
                          $stringRemovePair = "DELETE FROM Conversation_has_User WHERE conversationID = " . $idToRemove . ";";
                          $pdo->query($stringRemovePair);
                      }
                  }
              }

              if ($num < 1) {
                  echo "<h4>Doctor-Patient pairing doesn't exist!</h4>";
              }
              else {
                  echo "<h4>Success!</h4>";
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
