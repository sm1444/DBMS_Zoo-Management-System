<?php
session_start();
include('includes/dbconnection.php');
error_reporting(0);

// Redirect to logout page if session is not set
if (strlen($_SESSION['zmsaid']) == 0) {
    header('location:logout.php');
    exit(); // Stop further execution
} else {
    if (isset($_POST['submit'])) {
        $vname = $_POST['visitorname'];
        $noadult = $_POST['noadult'];
        $nochildren = $_POST['nochildren'];
        $aprice = $_POST['aprice'];
        $cprice = $_POST['cprice'];
        $ticketid = mt_rand(100000000, 999999999);

        // Insert into the tblticindian table
        $query = mysqli_query($con, "INSERT INTO tblticindian (visitorName, TicketID, NoAdult, NoChildren, AdultUnitprice, ChildUnitprice) VALUES ('$vname', '$ticketid', '$noadult', '$nochildren', '$aprice', '$cprice')");
        if ($query) {
            // Call the CalculateAndInsertRevenue function
            $sql = "SELECT CalculateAndInsertRevenue(?, ?, ?, ?) AS revenue_id";
            $stmt = mysqli_prepare($con, $sql);
            if ($stmt) {
                // Bind parameters to the prepared statement
                mysqli_stmt_bind_param($stmt, "iidd", $noadult, $nochildren, $aprice, $cprice);

                // Execute the statement
                mysqli_stmt_execute($stmt);

                // Bind result variables
                mysqli_stmt_bind_result($stmt, $revenueId);

                // Fetch the result
                mysqli_stmt_fetch($stmt);

                // Close the statement
                mysqli_stmt_close($stmt);

                // Output the generated revenue ID (if needed)
                echo "Generated Revenue ID: " . $revenueId;
            } else {
                // Handle error if the statement preparation fails
                echo "Failed to prepare statement for revenue calculation.";
            }

            // Add success message and redirect after ticket generation
            echo '<script>alert("Ticket has been generated")</script>';
            echo "<script>window.location.href='view-normal-ticket.php?viewid=$ticketid'</script>";
            exit(); // Stop further execution
        } else {
            // Handle error if ticket generation fails
            echo '<script>alert("Failed to generate ticket. Please try again.")</script>';
        }
    }
}
?>

<!doctype html>
<html class="no-js" lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Add Normal Zoo Ticket - Anantara</title>
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
                                        <h4 class="header-title">Add Normal Zoo Ticket</h4>
                                        <form method="post" action="" name="">
                                            <div class="form-group">
                                                <label for="exampleInputEmail1">Visitor Name</label>
                                                <input type="text" class="form-control" id="visitorname" name="visitorname" aria-describedby="emailHelp" placeholder="Visitor Name" value="" required="true">
                                            </div>
                                            <div class="form-group">
                                                <label for="exampleInputEmail1">Adult</label>
                                                <input type="text" class="form-control" id="noadult" name="noadult" aria-describedby="emailHelp" placeholder="No. of Adult" value="" required="true">
                                            </div>
                                            <div class="form-group">
                                                <label for="exampleInputEmail1">Children</label>
                                                <input type="text" class="form-control" id="nochildren" name="nochildren" aria-describedby="emailHelp" placeholder="No. of Childrens" value="" required="true">
                                            </div>
                                            <?php
                                                $ret=mysqli_query($con,"select * from tbltickettype where TicketType='Normal Adult'");
                                                while ($row=mysqli_fetch_array($ret)) {
                                            ?>
                                            <input type="hidden" name="aprice" value="<?php echo $row['Price'];?>">
                                            <?php } ?>
                                            <?php
                                                $ret=mysqli_query($con,"select * from tbltickettype where TicketType='Normal Child'");
                                                while ($row=mysqli_fetch_array($ret)) {
                                            ?>
                                            <input type="hidden" name="cprice" value="<?php echo $row['Price'];?>">
                                            <?php } ?>
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
        <!--
