<?php
// Allow from any origin
if (isset($_SERVER['HTTP_ORIGIN'])) {
    header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Max-Age: 86400');
}

// Access-Control headers are received during OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
        header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
        header("Access-Control-Allow-Headers: {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");
    exit(0);
}

include_once 'connect.php';
include_once 'courseslist.php';

$database = new Database();
$db = $database->getConnection();
$courseslist = new CoursesList($db);

// Return all courses data
$courses_arr = $courseslist->read();
http_response_code(200);
echo json_encode($courses_arr);

$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'GET') {
    // Fetch all courses
    $courses_arr = $courseslist->read();
    http_response_code(200);
    echo json_encode($courses_arr);
} elseif ($method == 'DELETE') {
    // Delete a course
    $data = json_decode(file_get_contents('php://input'), true);
    if ($courseslist->delete($data['name'])) {
        http_response_code(200);
        echo json_encode(["message" => "Course deleted successfully."]);
    } else {
        http_response_code(500);
        echo json_encode(["message" => "Failed to delete course."]);
    }
} else {
    // Other request methods
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
