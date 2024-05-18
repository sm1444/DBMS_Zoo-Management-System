<?php
session_start();
include('includes/dbconnection.php');
error_reporting(E_ALL);

if (empty($_SESSION['zmsaid'])) {
    header('location: logout.php');
    exit(); // Stop further execution
}
$query = "SELECT MAX(health_id) AS max_health FROM health_status";
$result = mysqli_query($con, $query);

if ($result) {
    $row = mysqli_fetch_assoc($result);
    if ($row['max_health'] !== null) {
        $next_health = $row['max_health'] + 1; // Increment by 1 to get the next available ID
    } else {
        $next_health = 1; // If no records found, set the ID to 1
    }
} else {
    echo 'Error: Unable to fetch next Health ID. ' . mysqli_error($con);
    // You can handle this error further as per your requirement
}
if (isset($_POST['submit'])) {
    $healthid = $_POST['id'];
    $animalid = $_POST['animalid'];
    $last_checkup_date = $_POST['lastcheckup'];
    $next_checkup_date = $_POST['nextcheckup'];
    $vetid = $_POST['veterinarian'];
    $health = $_POST['health'];

    // Prepare the SQL statement with placeholders
    $sql = "CALL AddHealthStatus(?, ?, ?, ?, ?, ?)";
    $stmt = mysqli_prepare($con, $sql);

    if ($stmt) {
        // Bind parameters to the prepared statement
        mysqli_stmt_bind_param($stmt, "iissis", $healthid, $animalid, $last_checkup_date, $next_checkup_date, $vetid, $health);

        // Execute the statement
        $result = mysqli_stmt_execute($stmt);

        if ($result) {
            echo '<script>alert("Health Condition added successfully")</script>';
        } else {
            echo '<script>alert("Failed to add health condition. Please try again.")</script>';
            echo 'MySQL Error: ' . mysqli_error($con);
        }
        
        // Close the statement
        mysqli_stmt_close($stmt);
    } else {
        echo '<script>alert("Failed to prepare statement. Please try again.")</script>';
        echo 'MySQL Error: ' . mysqli_error($con);
    }
}
?>

<!doctype html>
<html class="no-js" lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Add Health Detail - Anantara</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="shortcut icon" type="image/png" href="assets/images/icon/favicon.ico">
    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/font-awesome.min.css">
    <link rel="stylesheet" href="assets/css/themify-icons.css">
    <link rel="stylesheet" href="assets/css/metisMenu.css">
    <link rel="stylesheet" href="assets/css/owl.carousel.min.css">
    <link rel="stylesheet" href="assets/css/slicknav.min.css">
    <!-- amchart css -->
    <link rel="stylesheet" href="https://www.amcharts.com/lib/3/plugins/export/export.css" type="text/css" media="all" />
    <!-- others css -->
    <link rel="stylesheet" href="assets/css/typography.css">
    <link rel="stylesheet" href="assets/css/default-css.css">
    <link rel="stylesheet" href="assets/css/styles.css">
    <link rel="stylesheet" href="assets/css/responsive.css">
    <!-- modernizr css -->
    <script src="assets/js/vendor/modernizr-2.8.3.min.js"></script>
    <script src="http://js.nicedit.com/nicEdit-latest.js" type="text/javascript"></script>
<script type="text/javascript">bkLib.onDomLoaded(nicEditors.allTextAreas);</script>
</head>

<body>
    
    <!-- page container area start -->
    <div class="page-container">
        <!-- sidebar menu area start -->
     <?php include_once('includes/sidebar.php');?>
        <!-- sidebar menu area end -->
        <!-- main content area start -->
        <div class="main-content">
            <!-- header area start -->
          <?php include_once('includes/header.php');?>
            <!-- header area end -->
            <!-- page title area start -->
           <?php include_once('includes/pagetitle.php');?>
            <!-- page title area end -->
            <div class="main-content-inner">
                <div class="row">
          
                    <div class="col-lg-12 col-ml-12">
                        <div class="row">
                            <!-- basic form start -->
                            <div class="col-12 mt-5">
                                <div class="card">
                                    <div class="card-body">
                                        <h4 class="header-title">Add Health Condition</h4>
                                        <form method="post" enctype="multipart/form-data">
    <div class="form-group">
        <label for="id">Health ID</label>
        <input type="text" class="form-control" id="id" name="id" value="<?php echo $next_health; ?>" readonly>
    </div>
    <div class="form-group">
    <label for="animalid">Animal ID</label>
    <select class="form-control" id="animalid" name="animalid" required>
        <option value="">Select Animal ID</option>
        <?php
        $query = "SELECT ID, AnimalName FROM tblanimal";
        $result = mysqli_query($con, $query);
        while ($row = mysqli_fetch_array($result)) {
            echo "<option value='".$row['ID']."'>".$row['ID']." - ".$row['AnimalName']."</option>";
        }
        ?>
    </select>
</div>


    <div class="form-group">
        <label for="lastcheckup">Last CheckUp Date</label>
        <input type="date" class="form-control" id="lastcheckup" name="lastcheckup" placeholder="Enter Date" required>
    </div>
    <div class="form-group">
        <label for="nextcheckup">Next CheckUp Date</label>
        <input type="date" class="form-control" id="nextcheckup" name="nextcheckup" placeholder="Enter Date" required>
    </div>
    <div class="form-group">
        <label for="veterinarian">Veterinarian</label>
        <select class="form-control" id="veterinarian" name="veterinarian" required>
            <option value="">Select Veterinarian ID</option>
            <?php
            $query = "SELECT employee_id FROM employee WHERE job_type = 'veterinarian'";
            $result = mysqli_query($con, $query);
            while ($row = mysqli_fetch_array($result)) {
                echo "<option value='".$row['employee_id']."'>".$row['employee_id']."</option>";
            }
            ?>
        </select>
    </div>
    <div class="form-group">
        <label for="health">Health Condition</label>
        <select class="form-control" id="health" name="health" required>
            <option value="">Select Health Condition</option>
            <option value="Healthy">Healthy</option>
            <option value="Unhealthy">Unhealthy</option>
        </select>
    </div>
    <button type="submit" class="btn btn-primary mt-4 pr-4 pl-4" name="submit">Submit</button>
</form>


                                            
                                    </div>
                                </div>
                            </div>
                            <!-- basic form end -->
                         
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- main content area end -->
        <!-- footer area start-->
        <?php include_once('includes/footer.php');?>
        <!-- footer area end-->
    </div>
    <!-- page container area end -->
    <!-- offset area start -->
    
    <!-- jquery latest version -->
    <script src="assets/js/vendor/jquery-2.2.4.min.js"></script>
    <!-- bootstrap 4 js -->
    <script src="assets/js/popper.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src="assets/js/owl.carousel.min.js"></script>
    <script src="assets/js/metisMenu.min.js"></script>
    <script src="assets/js/jquery.slimscroll.min.js"></script>
    <script src="assets/js/jquery.slicknav.min.js"></script>

    <!-- others plugins -->
    <script src="assets/js/plugins.js"></script>
    <script src="assets/js/scripts.js"></script>
</body>

</html>
<?php   ?>