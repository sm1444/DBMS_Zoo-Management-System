<?php
session_start();
include('includes/dbconnection.php');
error_reporting(E_ALL);

if (strlen($_SESSION['zmsaid']) == 0) {
    header('location:logout.php');
}
else{

if (isset($_POST['submit'])) {
    $diagid = $_POST['diagnosis_id'];
    $animalid = $_POST['animalid'];
    $disease = $_POST['disease'];
    $medicine = $_POST['medicine'];

    // Prepare the SQL statement with placeholders
    $sql = "CALL AddDiagnosis(?, ?, ?, ?)";
    $stmt = mysqli_prepare($con, $sql);

    if ($stmt) {
        // Bind parameters to the prepared statement
        mysqli_stmt_bind_param($stmt, "iiss", $diagid, $animalid, $disease, $medicine);

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
}
?>

<!doctype html>
<html class="no-js" lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Add Diagnosis Detail - Anantara</title>
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
                                        <h4 class="header-title">Add Diagnosis</h4>
                                        <form method="post" enctype="multipart/form-data">
                                        <div class="form-group" style="display: none;">
    <label for="id">Diagnosis ID</label>
    <input type="text" class="form-control" id="diagid" name="diagid" value="<?php echo $next_diagid; ?>" readonly>
</div>

                                            <div class="form-group">
                                                <label for="animalid">Animal ID</label>
                                                <select class="form-control" id="animalid" name="animalid" required>
                                                    <option value="">Select Animal ID</option>
                                                        <?php
                                                            $query = "SELECT animal_id FROM health_status WHERE health = 'Unhealthy'";
                                                            $result = mysqli_query($con, $query);
                                                            while ($row = mysqli_fetch_assoc($result)) {
                                                                echo "<option value='".$row['animal_id']."'>".$row['animal_id']."</option>";
                                                            }
                                                            ?>
                                                </select>
                                            </div>

                                            <div class="form-group">
                                                <label for="lastcheckup">Disease</label>
                                                <input type="text" class="form-control" id="disease" name="disease" placeholder="Enter disease" required>
                                            </div>
                                            <div class="form-group">
                                                <label for="nextcheckup">Medicine</label>
                                                <input type="text" class="form-control" id="medicine" name="medicine" placeholder="Enter Medicine" required>
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
    <script src="assets/js/scripts.js"></
