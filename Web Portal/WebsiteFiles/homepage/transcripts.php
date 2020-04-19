<?php
require '../vendor/autoload.php';


//Redirect if not authenticated
session_start();
//if ($_SESSION["status"] != "true") {
    //header("Location: https://doctorsnote.ddns.net/index.html");
//}

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



//=======================Transcript Logic=====================//
if (isset($_POST['submitTrans'])) {
    $doctorIDinputTrans = $_POST['doctorIDinputTrans'];
    $patientIDinputTrans = $_POST['patientIDinputTrans'];

    if (isset($doctorIDinputTrans) && trim($doctorIDinputTrans) != ''
        && isset($patientIDinputTrans) && trim($patientIDinputTrans) != '') {

        //echo "<h4>" . $doctorIDinputTrans . "</h4>";
        //echo "<h4>" . $patientIDinputTrans . "</h4>";

        $resultID = $pdo->prepare('SELECT conversationID FROM Conversation_has_User WHERE userID =  ? ;');
        $resultID->execute(array($patientIDinputTrans));
        $num = $resultID->rowCount();
        //echo $num;
        while ($each = $resultID->fetch()) {
            foreach ($each as $convoID) {
                $matchedDoctor = $pdo->prepare('SELECT conversationID FROM Conversation_has_User WHERE userID = ? AND conversationID = ?;');
                $matchedDoctor->execute(array($doctorIDinputTrans, $convoID));

                $conversationsToDisplay = $matchedDoctor->fetchAll();
                foreach($conversationsToDisplay as $conversation) {
                    $messagesToDisplay = $pdo->prepare('SELECT receiverContent FROM Message WHERE conversationID = ? ORDER BY timeCreated ASC');
                    $messagesToDisplay->execute(array($conversation["conversationID"]));

                    //=======================The array $messagesToDisplay is the array containing all the message contents, ordered by date created=========================//
                    foreach($messagesToDisplay->fetchAll() as $indMessage) {
                        echo $indMessage["receiverContent"] . "\n";
                    }
                    //======================================================================================================================================================//
                }

            }
        }
    }
}


?>

<!doctype html>
<html lang="en">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

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
</head>

<body>

<div class="header">
    <a href="https://doctorsnote.ddns.net/homepage/index.php" class="logo">DoctorsNote</a>
    <div class="header-right">
        <a href="https://doctorsnote.ddns.net/homepage/index.php">Home</a>
        <!TODO: alter href to be online!>
        <a href="https://doctorsnote.ddns.net/homepage/accountManagement.php">Account Management</a>
        <a class="active" href="">Transcripts</a>
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
                          <td class=\"cell100 column4\">" . "</td>
                          <td class=\"cell100 column5\">" . $patientAttr[1]["Value"] . " " . $patientAttr[3]["Value"] . "</td>
                          <td class=\"cell100 column6\">" . $patientAttr[0]["Value"] . "</td>
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

<div>
    <h4>Select Conversation for Transcript</h4>
    <br/>
    <form class='form' method='post'>
        <label for='doctorIDinputTrans' class='labelNice'>Doctor ID:</label>
        <input class='input' name='doctorIDinputTrans'/>
        <label for='patientIDinputTrans' class = 'labelNice'>Patient ID:</label>
        <input class='input' name='patientIDinputTrans'/>
        <input class='submit' type='submit' name='submitTrans' value='Generate Transcript' />
    </form> <br>
</div>



<?php
echo "<br/>
   <h5>Please </h5>";
echo "<form class='form' method='post' onsubmit='setTimeout(window.location.reload, 200)'>";
echo "<input class='submit' type='submit' name='logout' value='logout' onclick='window.location.reload() '/>";
echo "</form>";
echo "<h5>before you leave the page</h5>";
?>
<br/>


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

