<?php

  require '../vendor/autoload.php';
  use Aws\CognitoIdentityProvider\CognitoIdentityProviderClient;
  use Aws\Exception\AwsException;

  //Instantiate the Cognito client
  
  $cognitoClient = new Aws\CognitoIdentityProvider\CognitoIdentityProviderClient([
    'region' => 'us-east-2',
    'version' => 'latest',
    //'profile' => 'default'
  ]);


  /*
  $cognitoClient = EC2Client::factory(array(
    //'profile' => 'default',
    'region' => 'us-east-2',
    'version' => 'latest',
  ));
  */


  /* $args = [
    'credentials' => [
      'key' => 'AKIAVJGAVBLHFCZH6ZP7',
      'secret' => '5LvxNU3sHi71p0jSmtZjVshlW2atPzG6+2tWknj',
    ],
    'region' => 'us-east-2',
    'version' => 'latest',

    'app_client_id' => '6ofohd4u4ba408d7ivl3a9ia5h',
    'app_client_secret' => '',
    'user_pool_id' => 'us-east-2_Cobrg1kBn',  
  ]*/

  //$client = new CognitoIdentityProviderClient($args);
  //$client->adminInitiateAuth([
    
//$cognitoClient->getCommand('listUsers');
   
  /* 
   $result = $cognitoClient->listUsers([
     'AttributesToGet' => array(
       "name"
     ),
     'Filter' => '',
     'Limit' => 3,
     'UserPoolId' => 'us-east-2_Cobrg1kBn',
   ]);

   echo $result;
   */

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
									<th class="cell100 column1">Username</th>
									<th class="cell100 column2">Name</th>
									<th class="cell100 column3">Birth Date</th>
									<th class="cell100 column4">Sex</th>
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


   $result = $cognitoClient->listUsers([
     'AttributesToGet' => array(
       "name",
       "birthdate",
       "gender"
     ),
     'Filter' => '',
     'Limit' => 60,
     'UserPoolId' => 'us-east-2_Cobrg1kBn',
   ]);


  foreach ($result['Users'] as $user) {
    echo "
    <tr>
      <td class='cell100 column1'>". $user['Username'] ."</td>";
      foreach ($user['Attributes'] as $attribute) {
        echo "<td class='cell100 column1'>". $attribute['Value'] ."</td>" . "\n";

        //echo $attribute['Name'] . " ";
        //echo $attribute['Value'] . "\n";
      }
    
    echo "</tr>
    ";
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

?>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>



  <div class="form">
  <form action="">
    <input type="number" name="DoctorID"/>
    <input class='submit' type='submit' name='location' value='update' />
  </form> 
  </div>
 



<?php
echo "
  <h2>Insert Doctor ID and Patient ID for Pairing</h2>
  <br />
  <form class='form' method='post'>
    <label for='doctorIDinputPair' class='labelNice'>Doctor ID:</label>
          <input class='input' type='number' name='doctorIDinputPair'/>
    <label for='patientIDinputPair' class = 'labelNice'>Patient ID:</label>
          <input class='input' type='number' name='patientIDinputPair'/>
  <br />
    <input class='submit' type='submit' name='submitpair' value='update' />
  </form>
";
  
  

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
