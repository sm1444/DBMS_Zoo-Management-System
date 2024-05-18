<?php
session_start();
include('includes/dbconnection.php'); 
error_reporting(0);

if (strlen($_SESSION['zmsaid']) == 0) {
    header('location:logout.php');
} else {
    if (isset($_POST['submit'])) {
        $id = $_POST['id'];
        $ename = $_POST['ename'];
        $job = $_POST['job'];
        $esalary = $_POST['esalary'];
        $emanager = $_POST['emanager'];

        // Prepare the SQL statement with placeholders
        $sql = "CALL AddEmployee(?, ?, ?, ?, ?)";
        $stmt = mysqli_prepare($con, $sql);

        if ($stmt) {
            // Bind parameters to the prepared statement
            mysqli_stmt_bind_param($stmt, "issds", $id, $ename, $job, $esalary, $emanager);

            // Execute the statement
            $result = mysqli_stmt_execute($stmt);

            if ($result) {
                // Insert into the expenditure table
                $expenseName = "Salary for Employee ID $id";
                $sqlInsertExpenditure = "INSERT INTO expenditure (expense_name, amount, date) VALUES (?, ?, NOW())";
                $stmtInsertExpenditure = mysqli_prepare($con, $sqlInsertExpenditure);

                if ($stmtInsertExpenditure) {
                    // Bind parameters to the prepared statement
                    mysqli_stmt_bind_param($stmtInsertExpenditure, "sd", $expenseName, $esalary);

                    // Execute the statement
                    $resultInsertExpenditure = mysqli_stmt_execute($stmtInsertExpenditure);

                    if ($resultInsertExpenditure) {
                        echo '<script>alert("Employee added successfully and expenditure updated")</script>';
                    } else {
                        echo '<script>alert("Employee added successfully but failed to update expenditure")</script>';
                    }

                    // Close the statement
                    mysqli_stmt_close($stmtInsertExpenditure);
                } else {
                    echo '<script>alert("Failed to prepare statement for expenditure insertion. Please try again.")</script>';
                    echo mysqli_error($con); // Output any MySQL errors
                }
            } else {
                echo '<script>alert("Failed to add employee. Please try again.")</script>';
                echo mysqli_error($con); // Output any MySQL errors
            }
        } else {
            echo '<script>alert("Failed to prepare statement for employee addition. Please try again.")</script>';
            echo mysqli_error($con); // Output any MySQL errors
        }

        // Close the statement
        mysqli_stmt_close($stmt);
    }
}

// Close database connection
mysqli_close($con);
?>




<!doctype html>
<html class="no-js" lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Add Employee - Anantara</title>
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
                                        <h4 class="header-title">Add Employee</h4>
                                        <form method="post" enctype="multipart/form-data">
    <div class="form-group">
        <label for="exampleInputEmail1">Employee ID</label>
        <input type="text" class="form-control" id="id" name="id" aria-describedby="emailHelp" placeholder="Enter Employee ID" required>
    </div>
    <div class="form-group">
        <label for="exampleInputEmail1">Employee Name</label>
        <input type="text" class="form-control" id="ename" name="ename" aria-describedby="emailHelp" placeholder="Enter Employee Name" required>
    </div>
    <div class="form-group">
        <label for="exampleInputEmail1">Job Type</label>
        <select class="form-control" id="job" name="job" required>
            <option value="">Select Job Type</option>
            <?php
            $query = "SELECT job_type FROM job";
            $result = mysqli_query($con, $query);
            while ($row = mysqli_fetch_array($result)) {
                echo "<option value='".$row['job_type']."'>".$row['job_type']."</option>";
            }
            ?>
        </select>
    </div>
    <div class="form-group">
        <label for="exampleInputEmail1">Salary</label>
        <input type="text" class="form-control" id="esalary" name="esalary" aria-describedby="emailHelp" placeholder="Enter Salary" required>
    </div>
    <div class="form-group">
        <label for="exampleInputEmail1">Manager</label>
        <input type="text" class="form-control" id="emanager" name="emanager" aria-describedby="emailHelp" placeholder="Enter Manager Name" required>
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