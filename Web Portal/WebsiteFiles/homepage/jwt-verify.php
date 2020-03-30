<script type = "text/javascript">
    var myRegex = /id_token=([^&]*)/;
    var fragment = window.location.hash.substr(1);
    let idToken = fragment.match(myRegex);
    if (idToken[1]) {
        alert(idToken[1]);
    } else {
        alert("Error!");
    }

    alert(pem);

    let out = isValid = KJUR.jws.JWS.verifyJWT(idToken[1], pem, {alg: ["RS256"]});
    alert(out);
</script>
<script>
    var pem = <?php echo json_encode($PEM); ?>;
</script>

<?php
require('./bootstrap.php');
use \Firebase\JWT\JWT;
use CoderCat\JWKToPEM\JWKConverter;


$jwkConverter = new JWKConverter();

$jwtsText = file_get_contents("https://cognito-idp.us-east-2.amazonaws.com/us-east-2_6dVeCsyh2/.well-known/jwks.json");
echo $jwtsText;

$jwts = json_decode($jwtsText, true);
//echo $jwts["keys"][0];

//Get the public key

$PEM = $jwkConverter->toPEM($jwts["keys"][0]);
echo $PEM;



//get the JWT
$jwt = "eyJraWQiOiJKUnlya2RVOUZ1ZHRJT2ZYMk5UbHd6SFJ1ejdMVlFcL2ZsUDZtS3liSVVBVT0iLCJhbGciOiJSUzI1NiJ9.eyJhdF9oYXNoIjoiWlY3M0VtZER4WG5hN3pJZC01SVVhZyIsInN1YiI6IjQxYmNiNjA2LWVjZTgtNDA2NC1hYzBiLTNmN2JjMmU3ZjdiNSIsImF1ZCI6IjUzOG8yOXQ3NGZnM20ydGs2MGNpYXNibXM0IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNTg1NTAwNzU1LCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0yLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMl82ZFZlQ3N5aDIiLCJjb2duaXRvOnVzZXJuYW1lIjoic21pdGgyMiIsImV4cCI6MTU4NTUwNDM1NSwiaWF0IjoxNTg1NTAwNzU1LCJlbWFpbCI6InNtaXQzMDE5QHB1cmR1ZS5lZHUifQ.F2DevSM7cYZMIJ4HLlOQj1V74uSNExEbPP4xwvxKcuDEp6h-g0JgJ0lwGlsCuQit_T8Z8zbsPulfA_HlY2tXzbvds7QLfDZf45IwOdkrNWENRE6LaBw4FxVSvgsZuHMELD_318JsAWYNH0Lx43DlrczmYYv8d33e4BSrEP4BnxtiDcYDZFX_LhuBwlXMnmokXtgzUF7AA3RdIyCBIBKbxPX1HjYBh65aK2iP0vGEDWyQzsnJ0hiWUGizQYdyKQ0izRghNOZhcdtkbYGG6-m7eML9ZczubwBbhOBwlVXGlP0o2sVHRbgDzFHj2MdLRAMhXa_UmDvsMkTk2-eEt0bKRA";
// = JWT::jsonEncode($publicKey);

//try {
    $decoded = JWT::decode($jwt, $PEM, ['RS256']);
//} catch (Exception $exception) {
    //echo "not verified!";
    //exit(-1);
//}
//echo "verified!";


