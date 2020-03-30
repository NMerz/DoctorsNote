<?php
session_start();
$_SESSION["status"] = "false";
require 'vendor/autoload.php';
use \Firebase\JWT\JWT;
use CoderCat\JWKToPEM\JWKConverter;

$jwkConverter = new JWKConverter();

$jwtsText = file_get_contents("https://cognito-idp.us-east-2.amazonaws.com/us-east-2_6dVeCsyh2/.well-known/jwks.json");
//echo $jwtsText;


$jwts = json_decode($jwtsText, true);
//echo $jwts["keys"][0];

//Get the public key

$PEM = $jwkConverter->toPEM($jwts["keys"][0]);
echo $PEM;

$jwt = $_GET['token'];
echo $jwt;

try {
    $decoded = JWT::decode($jwt, $PEM, ['RS256']);
}
catch (Exception $exception) {
    $_SESSION["login"] = "invalid";
    header("Location: https:doctorsnote.ddns.net/index.html");
}

$_SESSION['previous'] = basename($_SERVER['PHP_SELF']);
$_SESSION["status"] = "true";
header("Location: https://doctorsnote.ddns.net/homepage/index.php");

