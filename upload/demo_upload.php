<?php
$filename = basename($_FILES['file']['name']);

print_r($_FILES);
if (move_uploaded_file($_FILES['file']['tmp_name'], '/var/www/html/AutoTools/upload/'.$filename)) {
    $data = array('filename' => $filename);
} else {
    $data = array('error' => 'Failed to save');
}

header('Content-type: text/html');
echo json_encode($data);
 
?>
