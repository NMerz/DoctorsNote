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




//===============Logic for Adding/Removing a Doctor================//
$foundException = -1;
$filledOutForms = true;

if (isset($_POST['submitDoctor'])) {

    $addUsername = $_POST['username'];
    $addFirstname = $_POST['name'];
    $addMiddlename = $_POST['middlename'];
    $addFamilyname = $_POST['familyname'];
    $addGender = $_POST['gender'];
    $addPhonenumber = $_POST['phonenumber'];
    $addAddress = $_POST['address'];
    $addBirthdate = $_POST['birthdate'];

    if (isset($addUsername) && trim($addUsername) != ''
        && isset($addFirstname) && trim($addFirstname) != ''
        && isset($addMiddlename) && trim($addMiddlename) != ''
        && isset($addFamilyname) && trim($addFamilyname) != ''
        && isset($addGender) && trim($addGender) != ''
        && isset($addPhonenumber) && trim($addPhonenumber) != ''
        && isset($addAddress) && trim($addAddress) != ''
        && isset($addBirthdate) && trim($addBirthdate) != '') {

        //echo "<h4>Success!</h4>";
        //echo "<h4>" . $addMiddlename . "</h4>";

        $foundException = 0;
        try {
            $addedDoctor = $client->adminCreateUser([
                "DesiredDeliveryMediums" => ["EMAIL"],
                "ForceAliasCreation" => False,
                //"MessageAction" => "",
                //"TemporaryPassword" => "",
                "UserAttributes" => [
                    ["Name" => "name", "Value" => $addFirstname],
                    ["Name" => "middle_name", "Value" => $addMiddlename],
                    ["Name" => "family_name", "Value" => $addFamilyname],
                    ["Name" => "gender", "Value" => $addGender],
                    ["Name" => "phone_number", "Value" => "+1" . $addPhonenumber],
                    ["Name" => "address", "Value" => $addAddress],
                    ["Name" => "birthdate", "Value" => $addBirthdate],
                    ["Name" => "custom:role", "Value" => "doctor"]
                ],
                "Username" => $addUsername,
                "UserPoolId" => "us-east-2_Cobrg1kBn",
                //"ValidationData" => []
            ]);
        } catch (\Aws\CognitoIdentityProvider\Exception\CognitoIdentityProviderException $cognitoIdentityProviderException) {
            $foundException = 1;
        }

    } else {
        $filledOutForms = false;
    }


}



$foundDeleteException = -1;
if (isset($_POST['deleteDoctor'])) {
    $deleteDoctor = $_POST['usernameDelete'];

    $foundDeleteException = 0;
    if (isset($deleteDoctor) && trim($deleteDoctor) != '') {
        try {
            $deletedDoctor = $client->adminDeleteUser([
               "Username" => $deleteDoctor,
                "UserPoolId" => "us-east-2_Cobrg1kBn"
            ]);
        } catch (\Aws\CognitoIdentityProvider\Exception\CognitoIdentityProviderException $cognitoIdentityProviderException) {
            $foundDeleteException = 1;
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
        <a class="active" href="https://doctorsnote.ddns.net/homepage/accountManagement.php">Account Management</a>
        <a href="http://localhost/WebsiteFiles/homepage/transcripts.php">Transcripts</a>
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


<!--====================Creating an Account======================== -->
<div class="row">

    <div class="column">
        <h2>Create Doctor Account</h2>
        <br/>
        <form class="form" method="post">
            <label for="username" class="labelNice">Email</label>
            <input type="text" class="input" id="username" name="username" pattern=".*@.*">

            <label for="name" class="labelNice">First name</label>
            <input type="text" class="input" id="name" name="name">

            <label for="middlename" class="labelNice">Middle name</label>
            <input type="text" class="input" id="middlename" name="middlename">

            <label for="familyname" class="labelNice">Family name</label>
            <input type="text" class="input" id="familyname" name="familyname">

            <label for="gender" class="labelNice">Gender</label>
            <input type="text" class="input" id="gender" name="gender">

            <label for="phonenumber" class="labelNice">Phone number (10 digit no spaces)</label>
            <input type="text" class="input" id="phonenumber" name="phonenumber" pattern="[0-9]{10}" placeholder="1234567890">

            <label for="address" class="labelNice">Address</label>
            <input type="text" class="input" id="address" name="address">

            <label for="birthdate" class="labelNice">Birthdate</label>
            <input type="date" class="input" id="birthdate" name="birthdate" placeholder="yyyy-mm-dd">

            <input type="submit" class="submit" name="submitDoctor" value="Create Doctor"/>
        </form>

    <!-- Printing Error and Success messages -->
    <?php
        if (!$filledOutForms) {
            echo "<h4>Please fill out all the forms before submitting</h4>";
        } else if ($foundException == 1) {
            if ($cognitoIdentityProviderException["message"] == "Username should be either an email or a phone number.") {
                echo "<h4>Username should be an email.</h4>";
            } else {
                echo "<h4>" . $cognitoIdentityProviderException["message"] . "</h4>";
            }
        } else if ($foundException == 0) {
            echo "<h4>Doctor Account Successfully Created!</h4>";
        }
    ?>

    <br/>
    </div>

    <div class="column">
        <h2>Delete Doctor Account</h2>
        <br/>
        <form class="form" method="post">
            <label for="usernameDelete" class="labelNice">Doctor ID</label>
            <input type="text" class="input" id="usernameDelete" name="usernameDelete">

            <input type="submit" class="submit" name="deleteDoctor" value="Delete Doctor"/>
        </form>

        <?php
            if ($foundDeleteException == 1) {
                echo "<h4>" . $cognitoIdentityProviderException["message"] . "</h4>";
            } else if ($foundDeleteException == 0) {
                echo "<h4>Doctor Account Successfully Deleted!</h4>";
            }
        ?>


        <br/>
        <br/>
        <br/>

<!--===========================Disabling/Enabling Doctor Accounts============================-->
        <h2>Enable/Disable Doctor Accounts</h2>

    </div>

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
