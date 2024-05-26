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

$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['courses']) && is_array($data['courses'])) {
    if ($courseslist->create($data)) {
        http_response_code(200);
        echo json_encode(["message" => "Courses data stored successfully."]);
    } else {
        http_response_code(500);
        echo json_encode(["message" => "Failed to store courses data."]);
    }
} else {
    http_response_code(400);
    echo json_encode(["message" => "Invalid input data."]);
}

class CoursesList {
    private $conn;
    private $table_name = "courseslist";

    public function __construct($db) {
        $this->conn = $db;
    }

    function create($data) {
        $this->email = $data['email'];

        foreach ($data['courses'] as $course) {
            $this->coursename = $course['name'];
            $this->email = $course['email'];

            $query = "INSERT INTO " . $this->table_name . " (email, coursename) VALUES (:email, :coursename)";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(":email", $this->email);
            $stmt->bindParam(":coursename", $this->coursename);

            if (!$stmt->execute()) {
                error_log("Error executing query: " . implode(", ", $stmt->errorInfo()));
                return false;
            }
        }
        return true;
    }

    function read() {
        $query = "SELECT id, email, coursename FROM " . $this->table_name . " ORDER BY id ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $result;
    }
	function delete($name) {
        $query = "DELETE FROM " . $this->table_name . " WHERE coursename = :name";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":name", $name);
        return $stmt->execute();
    }
}
?>
