<?/*
if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
  $file = '/tmp/sample-app.log';
  $message = file_get_contents('php://input');
  file_put_contents($file, date('Y-m-d H:i:s') . " Received message: " . $message . "\n", FILE_APPEND);
}
else
{
*/?>


<!doctype html>
<html lang="en">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Lobster+Two" type="text/css">
    <link rel="shortcut icon" href="https://awsmedia.s3.amazonaws.com/favicon.ico" type="image/ico" >
    <!--[if IE]><script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script><![endif]-->
    <link rel="stylesheet" href="/styles.css" type="text/css">


<title>Table V04</title>
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
									<th class="cell100 column5">Sex</th>
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

reloadPage:

$resultPatient = $pdo->query("SELECT patientID, Username, Name, `Birth Date`, Sex 
FROM Patient
JOIN `Personal Information` ON Patient.personalInformationID = `Personal Information`.personalInformationID
ORDER BY Name;");

  while ($row = $resultPatient-> fetch()) {
    echo "<tr class=\"row100 head\">
            <td class=\"cell100 column1\">". $row["patientID"] ."</td>
            <td class=\"cell100 column2\">". $row["Name"] ."</td>
            <td class=\"cell100 column3\">". $row["Username"] ."</td>
            <td class=\"cell100 column4\">". $row["Birth Date"] ."</td>
            <td class=\"cell100 column5\">". $row["Sex"] ."</td>
          </tr>";
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

$resultDoctor = $pdo->query("SELECT doctorID, systemID, Name, Location
                             FROM Doctor
                             ORDER BY Name;");

  while ($row = $resultDoctor-> fetch()) {
    echo "<tr class=\"row100 head\">
            <td class=\"cell100 column1\">". $row["doctorID"] ."</td>
            <td class=\"cell100 column2\">". $row["Name"] ."</td>
            <td class=\"cell100 column3\">". $row["systemID"] ."</td>
            <td class=\"cell100 column4\">". $row["Location"] ."</td>
          </tr>";
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

$resultPair = $pdo->query("SELECT Doctor.doctorID, Doctor.Name as doc_name, Patient.patientID, Username, `Personal Information`.Name as pat_name, `Birth Date`
                               FROM Doctor_has_Patient 
                               JOIN Doctor ON Doctor.doctorID = Doctor_has_Patient.doctorID
                               JOIN Patient ON Doctor_has_Patient.patientID = Patient.patientID
                               JOIN `Personal Information` ON `Personal Information`.personalInformationID = Patient.personalInformationID
                               ORDER BY doc_name, pat_name;");

  while ($row = $resultPair-> fetch()) {
    echo "<tr class=\"row100 head\">
            <td class=\"cell100 column1\">". $row["doctorID"] ."</td>
              <td class=\"cell100 column2\">". $row["doc_name"] ."</td>
              <td class=\"cell100 column3\">". $row["patientID"] ."</td>
              <td class=\"cell100 column4\">". $row["Username"] ."</td>
              <td class=\"cell100 column5\">". $row["pat_name"] ."</td>
              <td class=\"cell100 column6\">". $row["Birth Date"] ."</td>
          </tr>";
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

<?php
  echo "<h2>Insert Doctor ID and Patient ID for Pairing</h2>";
  echo "<br>";
  echo "<form class='form' method='post'>";
  echo "<label for='doctorIDinputPair' class='labelNice'>Doctor ID:</label>
        <input class='input' type='number' name='doctorIDinputPair'/>";
  echo "<label for='patientIDinputPair' class = 'labelNice'>Patient ID:</label>
        <input class='input' type='number' name='patientIDinputPair'/>";
  //echo "<br />";
  echo "<input class='submit' type='submit' name='submitPair' value='update' />";
  echo "</form> <br>";

  if (isset($_POST['submitPair'])) {
    $doctorIDinputPair = $_POST['doctorIDinputPair'];
    $patientIDinputPair = $_POST['patientIDinputPair'];


    try {
      if (isset($doctorIDinputPair) && trim($doctorIDinputPair) != ''
          && isset($patientIDinputPair) && trim($patientIDinputPair) != '') {
        $pdo->query("INSERT INTO Doctor_has_Patient (doctorID, patientID)
                     VALUES ($doctorIDinputPair, $patientIDinputPair);");
        echo "<h4>Successfully Updated!</h4>";
      }
    }
    catch (PDOException $e) {
      if ($e->errorInfo[1] == 1062) {
        echo "<h4>Pairing already exists!</h4>";
      } else {
        echo "<h4>Something went wrong, make sure both the doctor and patient exist.</h4>";
      }
    }
    location.reload(true);
  }
?>

<br />

<?php
  echo "<h2>Insert Doctor ID and Patient ID for Un-Pairing</h2>";
  echo "<br>";
  echo "<form class='form' method='post'>";
  echo "<label for='doctorIDinputUnpair' class='labelNice'>Doctor ID:</label>
        <input class='input' type='number' name='doctorIDinputUnpair'/>";
  echo "<label for='patientIDinputUnpair' class = 'labelNice'>Patient ID:</label>
        <input class='input' type='number' name='patientIDinputUnpair'/>";
  //echo "<br />";
  echo "<input class='submit' type='submit' name='submitUnpair' value='update' />";
  echo "</form> <br>";

  if (isset($_POST['submitUnpair'])) {
    $doctorIDinputUnpair = $_POST['doctorIDinputUnpair'];
    $patientIDinputUnpair = $_POST['patientIDinputUnpair'];


    try {
      if (isset($doctorIDinputUnpair) && trim($doctorIDinputUnpair) != ''
          && isset($patientIDinputUnpair) && trim($patientIDinputUnpair) != '') {
        $pdo->query("DELETE FROM Doctor_has_Patient WHERE doctorID = $doctorIDinputUnpair AND patientID = $patientIDinputUnpair;");
        echo "<h4>Success!</h4>";
      }
    }
    catch (PDOException $e) {
      if ($e->errorInfo[1] == 1062) {
        echo "<h4>Oops! Something went wrong, please try again.</h4>";
      } else {
        echo "<h4>Something went wrong, make sure both the doctor and patient exist.</h4>";
      }
    }
    goto: reloadPage;
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
