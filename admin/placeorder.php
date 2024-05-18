<?php
session_start();
include('includes/dbconnection.php');

if (empty($_SESSION['zmsaid'])) {
    header('location:logout.php');
    exit(); // Ensure script execution stops after redirection
} else {
    if (isset($_POST['submit'])) {
        $itemID = $_POST['item'];
        $quantity = $_POST['quantity'];
        $itemName = $_POST['itemName'];

        // Call the function PlaceOrderAndUpdateExpense
        $sql = "SELECT PlaceOrderAndUpdateExpense($itemID, $quantity, '$itemName') AS order_id";
        $query = mysqli_query($con, $sql);

        if ($query) {
            $result = mysqli_fetch_assoc($query);
            $orderID = $result['order_id'];
            echo "<script>alert('Order placed successfully. Order ID: $orderID')</script>";
        } else {
            echo '<script>alert("Something Went Wrong. Please try again.")</script>';
            echo mysqli_error($con); // Output any MySQL errors
        }
    }
}
?>

<!doctype html>
<html class="no-js" lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <title>Add Animal Detail - Zoo Management System</title>
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
                                        <h4 class="header-title">Place order Details</h4>
                                        <form method="post" enctype="multipart/form-data">
                                            <div class="form-group">
                                                <label for="exampleInputEmail1">Item ID</label>
                                                <input type="text" class="form-control" id="item" name="item" aria-describedby="emailHelp" placeholder="Enter item ID" value="" required="true">
                                            </div>
                                            <div class="form-group">
                                                <label for="exampleInputEmail1">Quantity</label>
                                                <input type="number" class="form-control" id="quantity" name="quantity" aria-describedby="emailHelp" value="" required="true">

                                            </div>
                                            <div class="form-group">
                                                <label for="exampleInputEmail1">Item Name</label>
                                                <select class="form-control" id="itemName" name="itemName" required>
            <option value="">Select Food Name </option>
            <?php
            $query = "SELECT  distinct food_name FROM food";
            $result = mysqli_query($con, $query);
            while ($row = mysqli_fetch_array($result)) {
                echo "<option value='".$row['food_name']."'>".$row['food_name']."</option>";
            }
            ?>
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