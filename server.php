<?php
// server.php
// GNOENCRYPT

$stored_hash = hash("sha256", "letmein");
$key1 = "VZ0dguatW7_4UnQPTn1r8rxC8aznZ0w-ERL4CBwKAI4=";

$user_hash = isset($_GET['hash']) ? $_GET['hash'] : "";

// Accept hash with opt 'now' suffix
if (substr($user_hash, -3) === "now") {
    $user_hash = substr($user_hash, 0, -3);
}

if ($user_hash === $stored_hash) {
    // Return only the key
    header('Content-Type: text/plain');
    echo $key1;
    exit;
}
?>