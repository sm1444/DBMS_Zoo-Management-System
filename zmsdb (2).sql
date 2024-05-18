-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 26, 2024 at 10:17 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `zmsdb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAnimalToEvent` (IN `event_id_value` INT, IN `animal_id_value` INT)   BEGIN
    DECLARE animal_participation_exists INT;
    
    -- Check if the animal is already participating in the event
    SELECT COUNT(*) INTO animal_participation_exists
    FROM animal_participation
    WHERE event_id = event_id_value AND animal_id = animal_id_value;
    
    -- If the participation record already exists, do nothing
    IF animal_participation_exists > 0 THEN
        SELECT 'Animal is already participating in the event.' AS message;
        
    -- If the participation record does not exist, add it
    ELSE
        INSERT INTO animal_participation (event_id, animal_id)
        VALUES (event_id_value, animal_id_value);
        
        SELECT 'Animal added to the event.' AS message;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddDiagnosis` (IN `diagnosis_id_param` INT, IN `animal_id_param` INT, IN `disease_param` VARCHAR(100), IN `medicine_param` VARCHAR(100))   BEGIN
    INSERT INTO diagnosis (diagnosis_id,animal_id, disease, medicine)
    VALUES (diagnosis_id_param,animal_id_param, disease_param, medicine_param);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddEmployee` (IN `p_employee_id` INT, IN `p_employee_name` VARCHAR(255), IN `p_job_type` VARCHAR(100), IN `p_employee_salary` DECIMAL(10,2), IN `p_employee_manager` VARCHAR(100))   BEGIN
    INSERT INTO employee (employee_id,employee_name, job_type, employee_salary,employee_manager)
    VALUES (p_employee_id,p_employee_name, p_job_type, p_employee_salary,p_employee_manager);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddEvent` (IN `event_name` VARCHAR(100), IN `event_date` DATE, IN `animals_required` INT, IN `capacity` INT)   BEGIN
    DECLARE new_event_id INT;
    SELECT COALESCE(MAX(event_id), 0) + 1 INTO new_event_id FROM events;

    INSERT INTO events (event_id, event_name, event_date, animals_required, capacity)
    VALUES (new_event_id, event_name, event_date, animals_required, capacity);
    
    SELECT new_event_id AS inserted_event_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddFood` (IN `food_id_param` INT, IN `food_name_param` VARCHAR(100), IN `food_type_param` VARCHAR(100), IN `price_param` DECIMAL(10,2), IN `supplier_id_param` INT)   BEGIN
    INSERT INTO food (food_id, food_name, food_type, price, supplier_id)
    VALUES (food_id_param, food_name_param, food_type_param, price_param, supplier_id_param);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddHealthStatus` (IN `p_health_id` INT, IN `p_animal_id` INT, IN `p_last_checkup_date` DATE, IN `p_next_checkup_date` DATE, IN `p_vet_id` INT, IN `p_health` VARCHAR(100))   BEGIN
    INSERT INTO health_status(health_id,animal_id,last_checkup_date, next_checkup_date, vet_id,health)
    VALUES (p_health_id,p_animal_id,p_last_checkup_date, p_next_checkup_date, p_vet_id,p_health);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAnimalsAttendedBetweenDates` (IN `startDate` DATE, IN `endDate` DATE)   BEGIN
    SELECT tblanimal.ID, tblanimal.AnimalName, health_status.last_checkup_date, diagnosis.disease 
    FROM tblanimal 
    INNER JOIN health_status ON tblanimal.ID = health_status.animal_id 
    INNER JOIN diagnosis ON tblanimal.ID = diagnosis.animal_id
    WHERE health_status.last_checkup_date BETWEEN startDate AND endDate;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `AnimalsWithCheckupLast15Days` () RETURNS INT(11)  BEGIN
    DECLARE checkup_count INT;

    -- Count the number of animals with a checkup scheduled in the next 15 days
    SELECT COUNT(*) INTO checkup_count
    FROM health_status
    WHERE DATEDIFF( CURDATE(),last_checkup_date) <= 15;

    RETURN checkup_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `AnimalsWithCheckupNext15Days` () RETURNS INT(11)  BEGIN
    DECLARE animal_count INT;
    
    SELECT COUNT(*) INTO animal_count
    FROM health_status
    WHERE DATEDIFF(next_checkup_date, CURDATE()) BETWEEN 1 AND 15;
    
    RETURN animal_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CalculateAndInsertRevenue` (`NoAdult` INT, `NoChildren` INT, `AdultUnitPrice` DECIMAL(10,2), `ChildUnitPrice` DECIMAL(10,2)) RETURNS INT(11)  BEGIN
    DECLARE totalRevenue DECIMAL(10, 2);
    
    -- Calculate total revenue amount
    SET totalRevenue = (NoAdult * AdultUnitPrice) + (NoChildren * ChildUnitPrice);
    
    -- Insert revenue into the revenue table
    INSERT INTO revenue (revenue_source, revenue_amount)
    VALUES ('Ticket Sales', totalRevenue);

    -- Return the inserted revenue ID
    RETURN LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `calculateMoneyLeft` () RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total_income DECIMAL(10, 2);
    DECLARE total_expenditure DECIMAL(10, 2);
    DECLARE money_left DECIMAL(10, 2);

    -- Calculate total revenue
    SELECT IFNULL(SUM(revenue_amount), 0) INTO total_income FROM revenue;

    -- Calculate total expenditure
    SELECT IFNULL(SUM(amount), 0) INTO total_expenditure FROM expenditure;

    -- Calculate money left
    SET money_left = total_income - total_expenditure;

    RETURN money_left;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `calculateTicketRevenue` () RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT SUM(revenue_amount) INTO total
    FROM revenue;

    RETURN total;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `calculateTotalExpenses` () RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT SUM(amount) INTO total
    FROM expenditure;

    RETURN total;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountHealthyAnimals` () RETURNS INT(11)  BEGIN
    DECLARE healthy_count INT;
    
    SELECT COUNT(*) INTO healthy_count
    FROM tblanimal a
    JOIN health_status hs ON a.ID = hs.animal_id
    WHERE hs.health = 'Healthy';
    
    RETURN healthy_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `CountUnhealthyAnimals` () RETURNS INT(11)  BEGIN
    DECLARE unhealthy_count INT;
    
    -- Count the number of unhealthy animals
    SELECT COUNT(*) INTO unhealthy_count
    FROM tblanimal a
    JOIN health_status hs ON a.ID = hs.animal_id
    WHERE hs.health <> 'Healthy';
    
    RETURN unhealthy_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetMostUnhealthyAnimalType` () RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE max_unhealthy_count INT;
    DECLARE most_unhealthy_type VARCHAR(100);
    
    -- Find the maximum count of unhealthy animals among all types
    SELECT MAX(unhealthy_count) INTO max_unhealthy_count
    FROM (
        SELECT COUNT(*) AS unhealthy_count
        FROM tblanimal a
        INNER JOIN health_status hs ON a.ID = hs.animal_id
        WHERE hs.health != 'Healthy'
        GROUP BY a.Breed
    ) AS unhealthy_counts;

    -- Find the animal type with the maximum count of unhealthy animals
    SELECT animal_type INTO most_unhealthy_type
    FROM (
        SELECT a.Breed AS animal_type, COUNT(*) AS unhealthy_count
        FROM tblanimal a
        INNER JOIN health_status hs ON a.ID = hs.animal_id
        WHERE hs.health != 'Healthy'
        GROUP BY a.Breed
    ) AS animal_unhealthy_counts
    WHERE unhealthy_count = max_unhealthy_count
    LIMIT 1;
    
    RETURN most_unhealthy_type;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `HealthyAnimalPercentage` () RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total_animals INT;
    DECLARE healthy_count INT;
    DECLARE healthy_percentage DECIMAL(10, 2);
    
    -- Get the total number of animals
    SELECT COUNT(*) INTO total_animals FROM tblanimal;
    
    -- Get the count of healthy animals
    SELECT COUNT(*) INTO healthy_count FROM tblanimal a INNER JOIN health_status hs ON a.ID = hs.animal_id WHERE hs.health = 'Healthy';
    
    -- Calculate the percentage of healthy animals
    SET healthy_percentage = (healthy_count / total_animals) * 100;
    
    -- Return the percentage of healthy animals
    RETURN healthy_percentage;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `MostActiveVet` () RETURNS INT(11)  BEGIN
    DECLARE most_active_vet_id INT;

    -- Find the vet_id who has diagnosed or checked most of the animals
    SELECT vet_id INTO most_active_vet_id
    FROM (
        SELECT vet_id, COUNT(*) AS diagnosis_count
        FROM health_status
        GROUP BY vet_id
        ORDER BY diagnosis_count DESC
        LIMIT 1
    ) AS most_active_vet;

    RETURN most_active_vet_id;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `MostCommonDisease` () RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE common_disease VARCHAR(100);
    
    SELECT disease INTO common_disease
    FROM (
        SELECT disease, COUNT(*) AS diagnosis_count
        FROM diagnosis
        GROUP BY disease
        ORDER BY diagnosis_count DESC
        LIMIT 1
    ) AS most_common;
    
    RETURN common_disease;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `PlaceOrderAndUpdateExpense` (`pItemID` INT, `pQuantity` INT, `pItemName` VARCHAR(100)) RETURNS INT(11)  BEGIN
    DECLARE supplierID INT;
    DECLARE orderID INT;
    DECLARE totalAmount DECIMAL(10, 2);
    DECLARE itemPrice DECIMAL(10, 2);

    -- Get the supplier ID for the item
    SELECT supplier_id INTO supplierID FROM food WHERE food_id = pItemID;

    -- Get the price of the item from the food table
    SELECT price INTO itemPrice FROM food WHERE food_id = pItemID;

    -- Insert the order into the orders table
    INSERT INTO orders (item_id, supplier_id, quantity, order_date, item_name)
    VALUES (pItemID, supplierID, pQuantity, NOW(), pItemName);

    -- Get the ID of the newly inserted order
    SET orderID = LAST_INSERT_ID();

    -- Calculate the total amount
    SET totalAmount = pQuantity * itemPrice;

    -- Insert into the expenditure table
    INSERT INTO expenditure (expense_name, amount, date)
    VALUES (CONCAT('Order for ', pItemName), totalAmount, NOW());

    -- Return the order ID
    RETURN orderID;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `UnhealthyAnimalPercentage` () RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total_animals INT;
    DECLARE unhealthy_count INT;
    DECLARE unhealthy_percentage DECIMAL(10, 2);
    
    -- Get the total number of animals
    SELECT COUNT(*) INTO total_animals FROM tblanimal;
    
    -- Get the count of unhealthy animals
    SELECT COUNT(*) INTO unhealthy_count FROM tblanimal a INNER JOIN health_status hs ON a.ID = hs.animal_id WHERE hs.health = 'Unhealthy';
    
    -- Calculate the percentage of unhealthy animals
    SET unhealthy_percentage = (unhealthy_count / total_animals) * 100;
    
    -- Return the percentage of unhealthy animals
    RETURN unhealthy_percentage;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `UpdateExpenditureForSalaryChange` (`pEmployeeID` INT, `pNewSalary` DECIMAL(10,2)) RETURNS INT(11)  BEGIN
    DECLARE expenseName VARCHAR(255);
    DECLARE totalAmount DECIMAL(10, 2);

    -- Calculate the total amount
    SET totalAmount = pNewSalary;

    -- Get the employee name
    SELECT CONCAT('Salary for ', employee_name) INTO expenseName FROM employees WHERE employee_id = pEmployeeID;

    -- Insert into the expenditure table
    INSERT INTO expenditure (expense_name, amount, date)
    VALUES (expenseName, totalAmount, NOW());

    -- Return 1 to indicate success
    RETURN 1;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `animal_participation`
--

CREATE TABLE `animal_participation` (
  `id` int(11) NOT NULL,
  `event_id` int(11) NOT NULL,
  `animal_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `animal_participation`
--

INSERT INTO `animal_participation` (`id`, `event_id`, `animal_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(4, 1, 4),
(5, 1, 5);

--
-- Triggers `animal_participation`
--
DELIMITER $$
CREATE TRIGGER `animal_id_exists_trigger` BEFORE INSERT ON `animal_participation` FOR EACH ROW BEGIN
    DECLARE animal_count INT;
    
    -- Check if the entered animal ID exists in tblanimal
    SELECT COUNT(*) INTO animal_count FROM tblanimal WHERE ID = NEW.animal_id;
    
    -- If animal count is zero, rollback the insertion
    IF animal_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Animal ID does not exist in tblanimal';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_animal_requirement` BEFORE INSERT ON `animal_participation` FOR EACH ROW BEGIN
    DECLARE animal_count INT;
    DECLARE animal_requirement INT;

    -- Get the animal requirement for the event
    SELECT animals_required INTO animal_requirement
    FROM events
    WHERE event_id = NEW.event_id;

    -- Count the number of animals already participating in the event
    SELECT COUNT(*) INTO animal_count
    FROM animal_participation
    WHERE event_id = NEW.event_id;

    -- If the animal requirement is already fulfilled, prevent insertion
    IF animal_count >= animal_requirement THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Animal requirement already fulfilled for this event';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `diagnosis`
--

CREATE TABLE `diagnosis` (
  `diagnosis_id` int(11) NOT NULL,
  `animal_id` int(11) NOT NULL,
  `disease` varchar(100) NOT NULL,
  `medicine` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `diagnosis`
--

INSERT INTO `diagnosis` (`diagnosis_id`, `animal_id`, `disease`, `medicine`) VALUES
(1, 1, 'Influenza', 'medicine'),
(2, 2, 'Influenza', 'medicine'),
(3, 6, 'Fever', 'Paracetamol Animal'),
(4, 6, 'Fever', 'Paracetamol Animal'),
(5, 6, 'Fever', 'Paracetamol Animal'),
(6, 6, 'Fever', 'Paracetamol Animal'),
(7, 15, 'Influenza', 'Influenza medicine'),
(9, 8, 'Influenza', 'Influenza medicine'),
(10, 8, 'Influenza', 'Influenza medicine'),
(11, 12, 'Elephantiasis', 'Paracetamol Animal');

--
-- Triggers `diagnosis`
--
DELIMITER $$
CREATE TRIGGER `increment_diagnosis_id` BEFORE INSERT ON `diagnosis` FOR EACH ROW BEGIN
    DECLARE max_id INT;

    SELECT MAX(diagnosis_id) INTO max_id FROM diagnosis;

    IF max_id IS NOT NULL THEN
        SET NEW.diagnosis_id = max_id + 1; 
    ELSE
        SET NEW.diagnosis_id = 1; 
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `employee_id` int(11) NOT NULL,
  `employee_name` varchar(100) NOT NULL,
  `job_type` varchar(100) NOT NULL,
  `employee_salary` int(11) NOT NULL,
  `employee_manager` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`employee_id`, `employee_name`, `job_type`, `employee_salary`, `employee_manager`) VALUES
(1, 'Anusha Jain', 'Kitchen Staff', 10000, ''),
(2, 'Anusha Jain', 'Kitchen staff', 10000, ''),
(4, 'Mahi', 'Manager', 50000, ''),
(5, 'Shalvi', 'Manager', 50000, ''),
(6, 'Malav', 'Security', 5000, ''),
(10, 'Shalvi Modi', 'Manager', 100000, 'admin'),
(11, 'Jhanvi', 'veterinarian', 25000, 'admin'),
(18, 'Mahi', 'Manager', 100000, 'admin'),
(19, 'Mahi', 'Manager', 100000, 'admin'),
(20, 'Nita Ambani', 'Security', 25000, 'admin'),
(21, 'Nita Ambani', 'Event coordinator', 100000, 'admin'),
(22, 'Bill Gates', 'veterinarian', 25000, 'admin'),
(24, 'Mukesh Ambani', 'Guide', 25000, 'admin'),
(25, 'Ratan Tata', 'veterinarian', 25000, 'admin'),
(26, 'Rishi Modi', 'Event coordinator', 50000, 'Shalvi');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `event_id` int(11) NOT NULL,
  `event_name` varchar(100) NOT NULL,
  `event_date` date NOT NULL,
  `animals_required` int(11) NOT NULL,
  `capacity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`event_id`, `event_name`, `event_date`, `animals_required`, `capacity`) VALUES
(1, 'giraffe show', '2024-03-22', 5, 100),
(2, 'Anantara Trunk Show', '2024-03-26', 10, 100),
(3, 'Anantara Fest', '2024-03-28', 15, 100);

-- --------------------------------------------------------

--
-- Table structure for table `expenditure`
--

CREATE TABLE `expenditure` (
  `expense_id` int(11) NOT NULL,
  `expense_name` varchar(100) NOT NULL,
  `amount` int(11) NOT NULL,
  `date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expenditure`
--

INSERT INTO `expenditure` (`expense_id`, `expense_name`, `amount`, `date`) VALUES
(1, 'Order for Beef', 20000, '2024-03-24'),
(2, 'Salary for Employee ID 18', 100000, '2024-03-24'),
(3, 'Order for Item 1', 6000, '2024-03-25'),
(4, 'Salary for Employee ID 26', 50000, '2024-03-26'),
(5, 'Order for Meat', 100000, '2024-03-26'),
(6, 'Order for Plant', 100000, '2024-03-26'),
(7, 'Order for plant', 100000, '2024-03-26'),
(8, 'Order for meat', 12500, '2024-03-26'),
(9, 'Order for chicken', 12500, '2024-03-26'),
(10, 'Order for chicken', 12500, '2024-03-26'),
(11, 'Order for ', 1800, '2024-03-26'),
(12, 'Order for Meat', 7500, '2024-03-26');

-- --------------------------------------------------------

--
-- Table structure for table `food`
--

CREATE TABLE `food` (
  `food_id` int(11) NOT NULL,
  `food_name` varchar(100) NOT NULL,
  `food_type` varchar(100) NOT NULL,
  `price` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `food`
--

INSERT INTO `food` (`food_id`, `food_name`, `food_type`, `price`, `supplier_id`) VALUES
(1, 'Meat', 'Carnivore', 200, 3),
(3, 'Chicken', 'Carnivore', 250, 3),
(4, 'Chicken', 'Carnivore', 250, 3),
(5, 'vegetable', 'herbivore', 60, 3);

--
-- Triggers `food`
--
DELIMITER $$
CREATE TRIGGER `increment_food_id` BEFORE INSERT ON `food` FOR EACH ROW BEGIN
    DECLARE max_id INT;
    
    SELECT MAX(food_id) INTO max_id FROM food;
    
    IF max_id IS NULL THEN
        SET NEW.food_id = 1;
    ELSE
        SET NEW.food_id = max_id + 1;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `health_status`
--

CREATE TABLE `health_status` (
  `health_id` int(11) NOT NULL,
  `animal_id` int(11) NOT NULL,
  `last_checkup_date` date NOT NULL,
  `next_checkup_date` date NOT NULL,
  `vet_id` int(11) NOT NULL,
  `health` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `health_status`
--

INSERT INTO `health_status` (`health_id`, `animal_id`, `last_checkup_date`, `next_checkup_date`, `vet_id`, `health`) VALUES
(1, 1, '2024-03-01', '2024-03-31', 11, 'Healthy'),
(2, 2, '2024-03-18', '2024-03-27', 11, 'Unhealthy'),
(23, 6, '2024-01-01', '2024-04-01', 11, 'Unhealthy'),
(24, 8, '2024-03-12', '2024-03-27', 22, 'Unhealthy'),
(25, 18, '2024-03-24', '2024-03-29', 25, 'Healthy'),
(26, 16, '2024-03-24', '2024-03-27', 25, 'Healthy'),
(27, 15, '2024-03-10', '2024-03-18', 25, 'Unhealthy'),
(28, 12, '2024-03-24', '2024-03-29', 22, 'Unhealthy');

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `item_id` int(11) NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `reorder_level` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`item_id`, `item_name`, `description`, `quantity`, `reorder_level`, `supplier_id`) VALUES
(1, 'Item 1', 'Description of item 1', 1696, 10, 1),
(2, 'Chicken', 'Carnivore food', 500, 112, 3);

-- --------------------------------------------------------

--
-- Table structure for table `job`
--

CREATE TABLE `job` (
  `id` int(11) NOT NULL,
  `job_type` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `job`
--

INSERT INTO `job` (`id`, `job_type`) VALUES
(2, 'Event coordinator'),
(3, 'Guide'),
(5, 'Kitchen staff'),
(1, 'Manager'),
(4, 'Sanitation worker'),
(6, 'Security'),
(7, 'veterinarian');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `order_date` date NOT NULL,
  `item_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `item_id`, `supplier_id`, `quantity`, `order_date`, `item_name`) VALUES
(1, 2, 2, 55, '2024-03-24', 'ItemName'),
(2, 2, 2, 55, '2024-03-24', 'Meat'),
(4, 2, 2, 100, '2024-03-24', 'Beef'),
(5, 1, 1, 30, '2024-03-25', 'Item 1'),
(14, 1, 1, 500, '2024-03-26', 'Meat'),
(15, 1, 1, 500, '2024-03-26', 'Plant'),
(19, 1, 1, 500, '2024-03-26', 'plant'),
(21, 3, 3, 50, '2024-03-26', 'meat'),
(22, 4, 3, 50, '2024-03-26', 'chicken'),
(23, 4, 3, 50, '2024-03-26', 'chicken'),
(24, 5, 3, 30, '2024-03-26', ''),
(25, 3, 3, 30, '2024-03-26', 'Meat');

-- --------------------------------------------------------

--
-- Table structure for table `revenue`
--

CREATE TABLE `revenue` (
  `revenue_id` int(11) NOT NULL,
  `revenue_source` varchar(100) NOT NULL,
  `revenue_amount` int(11) NOT NULL,
  `date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `revenue`
--

INSERT INTO `revenue` (`revenue_id`, `revenue_source`, `revenue_amount`, `date`) VALUES
(1, 'Ticket Sales', 1100, '0000-00-00'),
(2, 'Ticket Sales', 1100, '0000-00-00'),
(3, 'Ticket Sales', 300, '0000-00-00'),
(4, 'Ticket Sales', 2200, '0000-00-00'),
(5, 'Ticket Sales', 4400, '0000-00-00'),
(6, 'Ticket Sales', 980, '0000-00-00'),
(7, 'Ticket Sales', 1360, '0000-00-00'),
(8, 'Ticket Sales', 4400, '0000-00-00'),
(9, 'Ticket Sales', 760, '0000-00-00'),
(10, 'Ticket Sales', 760, '0000-00-00'),
(11, 'Ticket Sales', 190000, '0000-00-00'),
(12, 'Ticket Sales', 950000, '0000-00-00');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `supplier_id` int(11) NOT NULL,
  `supplier_name` varchar(100) NOT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `supplied_item_type` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`supplier_id`, `supplier_name`, `contact_person`, `email`, `phone`, `supplied_item_type`) VALUES
(1, 'Supplier A', 'Malav Modi', 'malav@example.com', '123-456-7890', ''),
(2, 'Supplier B', 'Daksh Shah', 'daksh@example.com', '987-654-3210', ''),
(3, 'Supplier C', 'Mahi Patel', 'mahi@gmail.com', '345-456-2345', 'food');

-- --------------------------------------------------------

--
-- Table structure for table `tbladmin`
--

CREATE TABLE `tbladmin` (
  `ID` int(10) NOT NULL,
  `AdminName` varchar(120) DEFAULT NULL,
  `UserName` varchar(50) DEFAULT NULL,
  `MobileNumber` bigint(10) DEFAULT NULL,
  `Email` varchar(120) DEFAULT NULL,
  `Password` varchar(120) DEFAULT NULL,
  `AdminRegdate` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tbladmin`
--

INSERT INTO `tbladmin` (`ID`, `AdminName`, `UserName`, `MobileNumber`, `Email`, `Password`, `AdminRegdate`) VALUES
(1, 'Anantara', 'admin', 1234567890, 'admin@gmail.com', 'f925916e2754e5e03f75dd58a5733251', '2024-01-31 16:08:00');

-- --------------------------------------------------------

--
-- Table structure for table `tblanimal`
--

CREATE TABLE `tblanimal` (
  `ID` int(10) NOT NULL,
  `AnimalName` varchar(200) DEFAULT NULL,
  `CageNumber` int(10) DEFAULT NULL,
  `FeedNumber` varchar(200) DEFAULT NULL,
  `Breed` varchar(200) DEFAULT NULL,
  `AnimalImage` varchar(200) DEFAULT NULL,
  `Description` mediumtext DEFAULT NULL,
  `CreationDate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `health_condition` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tblanimal`
--

INSERT INTO `tblanimal` (`ID`, `AnimalName`, `CageNumber`, `FeedNumber`, `Breed`, `AnimalImage`, `Description`, `CreationDate`, `health_condition`) VALUES
(1, 'Giraffe', 12300, 'FN-123', 'Masai giraffe', '694cb29edd30cd1d86dda55dd904ee4b1596609931.jpg', 'The Masai giraffe (Giraffa camelopardalis tippelskirchii), also spelled Maasai giraffe, also called Kilimanjaro giraffe, is the largest subspecies of giraffe. It is native to East Africa. The Masai giraffe can be found in central and southern Kenya and in Tanzania.', '2024-03-22 08:17:29', ''),
(2, 'Giraffe', 12301, 'F-5688', 'Reticulated giraffe', '7fdc1a630c238af0815181f9faa190f51596609868.jpg', 'The reticulated giraffe (Giraffa camelopardalis reticulata), also known as the Somali giraffe, is a subspecies of giraffe native to the Horn of Africa. It lives in Somalia, southern Ethiopia, and northern Kenya. There are approximately 8,500 individuals living in the wild.', '2024-02-14 13:00:00', ''),
(3, 'Tiger', 12302, 'FN-809', 'Bengal Tiger', 'e692bd84570d9f467b75af761bf15c7c1596609789.jpg', 'The Bengal tiger is a tiger from a specific population of the Panthera tigris tigris subspecies that is native to the Indian subcontinent. It is threatened by poaching, loss, and fragmentation of habitat, and was estimated at comprising fewer than 2,500 individuals by 2011.', '2024-02-14 13:00:00', ''),
(4, 'Tiger', 12303, 'FN-798', ' Indochinese Tiger', '031a51aa205bd3138f7afeb0d86999e51596611280.png', 'The Indochinese tiger is a tiger from a specific population of the Panthera tigris tigris subspecies that is native to Southeast Asia. This population occurs in Myanmar, Thailand, Laos, Vietnam, Cambodia and southwestern China.', '2024-02-14 13:00:00', ''),
(5, 'Tiger', 12304, 'FN-787', 'Siberian Tiger', '1e6ae4ada992769567b71815f124fac51596609708.jpg', 'The Siberian tiger is a tiger from a specific population of the Panthera tigris tigris subspecies that is native to the Russian Far East, Northeast China, and possibly North Korea. It once ranged throughout the Korean Peninsula, north China, Russian Far East, and eastern Mongolia.', '2024-02-14 13:00:00', ''),
(6, 'Tiger', 12305, 'FN-345', 'Indochinese Tiger', '37b3f2f8b979f990fbe8bbf02fb87ddb1596609488.jpg', 'The Indochinese tiger is a tiger from a specific population of the Panthera tigris tigris subspecies that is native to Southeast Asia. This population occurs in Myanmar, Thailand, Laos, Vietnam, Cambodia and southwestern China.', '2024-02-14 13:00:00', ''),
(7, 'Bear', 12307, 'FN-0123', 'Sloth Bear', 'efc1a80c391be252d7d777a437f868701596611141.jpg', 'The sloth bear (Melursus ursinus) is a myrmecophagous bear species native to the Indian subcontinent. It feeds on fruits, ants and termites. It is listed as Vulnerable on the IUCN Red List, mainly because of habitat loss and degradation.', '2024-02-14 13:00:00', ''),
(8, 'Bear', 12308, 'FN-090', 'Sun Bear', '6c09a06117fd4daa8fd74f6d1560d6a01596609406.jpg', 'The sun bear (Helarctos malayanus) is a species in the family Ursidae occurring in the tropical forests of Southeast Asia. It is the smallest bear, standing nearly 70 centimetres (28 inches) at the shoulder and weighing 25–65 kilograms (55–143 pounds). It is stockily built, with large paws, strongly curved claws, small rounded ears and a short snout. The fur is generally jet-black, but can vary from grey to red. Sun bears get their name from the characteristic orange to cream coloured chest patch. Its unique morphology—inward-turned front feet, flattened chest, powerful forelimbs with large claws—suggests adaptations for climbing.', '2024-02-14 13:00:00', ''),
(10, 'Elephant', 12309, 'FN1230', 'Indian Elephant', 'e4121023aff8f6b0b111cf1ccddad8b91711352076jpeg', 'The Indian elephant (Elephas maximus indicus) is one of three extant recognized subspecies of the Asian elephant and native to mainland Asia.', '2024-03-25 07:34:36', ''),
(11, 'Elephant', 12309, 'FN1231', 'Indian Elephant', 'e4121023aff8f6b0b111cf1ccddad8b91711352126jpeg', 'The Indian elephant (Elephas maximus indicus) is one of three extant recognized subspecies of the Asian elephant and native to mainland Asia.', '2024-03-25 07:35:26', ''),
(12, 'Elephant', 12309, 'FN1232', 'Indian Elephant', 'e4121023aff8f6b0b111cf1ccddad8b91711352146jpeg', 'The Indian elephant (Elephas maximus indicus) is one of three extant recognized subspecies of the Asian elephant and native to mainland Asia.', '2024-03-25 07:35:46', ''),
(13, 'Rhino', 12310, 'FN1234', 'Indian Rhino', 'e129ccfdd10db9c46649f43e9ee45fc51711352193jpeg', 'The Indian rhinoceros (Rhinoceros unicornis), also called the greater one-horned rhinoceros, is native to the Indian subcontinent.', '2024-03-25 07:36:33', ''),
(14, 'Rhino', 12310, 'FN1235', 'Indian Rhino', 'e129ccfdd10db9c46649f43e9ee45fc51711352216jpeg', 'The Indian rhinoceros (Rhinoceros unicornis), also called the greater one-horned rhinoceros, is native to the Indian subcontinent.', '2024-03-25 07:36:56', ''),
(15, 'Lion', 12311, 'FN1236', 'Asiatic Lion', '69f4a6b747547168fdf8a5b9727cc6261711352253jpeg', 'The Indian lion (Panthera leo persica) is a subspecies of the lion native to India. It is listed as Endangered on the IUCN Red List.', '2024-03-25 07:37:33', ''),
(16, 'Lion', 12311, 'FN1237', 'Asiatic Lion', '69f4a6b747547168fdf8a5b9727cc6261711352274jpeg', 'The Indian lion (Panthera leo persica) is a subspecies of the lion native to India. It is listed as Endangered on the IUCN Red List.', '2024-03-25 07:37:54', ''),
(17, 'Tiger', 12312, 'FN1238', 'The Bengal Tiger', '961c337ea9c8e23d5b5c147ea8a815e91711352345jpeg', 'The Bengal tiger (Panthera tigris tigris) is native to the Indian subcontinent, and is listed as Endangered on the IUCN Red List.', '2024-03-25 07:39:05', ''),
(18, 'Leopard', 12313, 'FN1239', 'Indian Leopard', 'ecb215d7887cd5cca1b41a205799220e1711353219jpeg', 'The Indian leopard (Panthera pardus fusca) is widely distributed in the Indian subcontinent.', '2024-03-25 07:53:39', ''),
(19, 'Leopard', 12313, 'FN1240', 'Indian Leopard', 'ecb215d7887cd5cca1b41a205799220e1711353244jpeg', 'The Indian leopard (Panthera pardus fusca) is widely distributed in the Indian subcontinent.', '2024-03-25 07:54:04', ''),
(20, 'Leopard', 12313, 'FN1241', 'Indian Leopard', 'ecb215d7887cd5cca1b41a205799220e1711353268jpeg', 'The Indian leopard (Panthera pardus fusca) is widely distributed in the Indian subcontinent.', '2024-03-25 07:54:28', ''),
(21, 'Crocodile', 12314, 'FN1242', 'Indian Crocodile', '0f1122ecb3e492185d183f9d0b25cc371711353325jpeg', 'The mugger crocodile (Crocodylus palustris), also called the Indian, Indus, Persian, or marsh crocodile, is found throughout the Indian subcontinent.', '2024-03-25 07:55:25', ''),
(22, 'Peacock', 12315, 'FN1243', 'Indian Peacock', 'd34e7efa1621a299bdcfdaa31b6388b91711353377jpeg', 'The Indian peafowl (Pavo cristatus) is native to the Indian subcontinent and is the national bird of India.', '2024-03-25 07:56:17', '');

--
-- Triggers `tblanimal`
--
DELIMITER $$
CREATE TRIGGER `check_feed_number` BEFORE INSERT ON `tblanimal` FOR EACH ROW BEGIN
    DECLARE feed_count INT;
    
    SELECT COUNT(*) INTO feed_count 
    FROM tblanimal 
    WHERE FeedNumber = NEW.FeedNumber;
    
    IF feed_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'This feed number is already allotted to another animal';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tblpage`
--

CREATE TABLE `tblpage` (
  `ID` int(10) NOT NULL,
  `PageType` varchar(200) DEFAULT NULL,
  `PageTitle` varchar(200) DEFAULT NULL,
  `PageDescription` mediumtext DEFAULT NULL,
  `Email` varchar(200) DEFAULT NULL,
  `MobileNumber` bigint(10) DEFAULT NULL,
  `UpdationDate` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tblpage`
--

INSERT INTO `tblpage` (`ID`, `PageType`, `PageTitle`, `PageDescription`, `Email`, `MobileNumber`, `UpdationDate`) VALUES
(1, 'aboutus', 'About us', 'We understand that running your business is hard work. This is a game-changer when it comes to family activity center software. Clubspeed develops and adapts our solution specifically for the needs of your business; simply sit back, relax, and let us do all the heavy lifting. Then the fun will truly begin!<div><br></div>', NULL, NULL, '2024-02-09 21:29:31'),
(2, 'contactus', 'Contact Us', '#890 CFG Apartment, Mayur Vihar, Delhi-India.', 'info@gmail.com', 1111111111, '2024-02-09 21:29:31');

-- --------------------------------------------------------

--
-- Table structure for table `tblticforeigner`
--

CREATE TABLE `tblticforeigner` (
  `ID` int(10) NOT NULL,
  `TicketID` varchar(200) DEFAULT NULL,
  `visitorName` varchar(250) DEFAULT NULL,
  `NoAdult` int(10) DEFAULT NULL,
  `NoChildren` int(10) DEFAULT NULL,
  `AdultUnitprice` varchar(50) DEFAULT NULL,
  `ChildUnitprice` varchar(50) DEFAULT NULL,
  `PostingDate` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tblticforeigner`
--

INSERT INTO `tblticforeigner` (`ID`, `TicketID`, `visitorName`, `NoAdult`, `NoChildren`, `AdultUnitprice`, `ChildUnitprice`, `PostingDate`) VALUES
(5, '322093419', 'Shalvi Modi', 2, 0, '1100', '800', '2024-03-25 05:40:54'),
(6, '572255115', 'Daksh Shah', 4, 0, '1100', '800', '2024-03-25 05:47:07'),
(7, '612084651', 'Rishi Modi', 4, 0, '1100', '800', '2024-03-25 09:56:35'),
(8, '715996757', 'Tashyla', 100, 100, '1100', '800', '2024-03-26 08:57:06'),
(9, '285380628', 'Liam', 500, 500, '1100', '800', '2024-03-26 08:57:41');

-- --------------------------------------------------------

--
-- Table structure for table `tblticindian`
--

CREATE TABLE `tblticindian` (
  `ID` int(10) NOT NULL,
  `TicketID` varchar(100) NOT NULL,
  `visitorName` varchar(255) DEFAULT NULL,
  `NoAdult` int(10) DEFAULT NULL,
  `NoChildren` int(10) DEFAULT NULL,
  `AdultUnitprice` varchar(50) DEFAULT NULL,
  `ChildUnitprice` varchar(50) DEFAULT NULL,
  `PostingDate` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tblticindian`
--

INSERT INTO `tblticindian` (`ID`, `TicketID`, `visitorName`, `NoAdult`, `NoChildren`, `AdultUnitprice`, `ChildUnitprice`, `PostingDate`) VALUES
(2, '911666414', 'Atul singh', 2, 0, '350', '80', '2024-02-16 20:09:41'),
(3, '562063870', 'Anuj kumar', 4, 1, '300', '80', '2024-02-16 11:13:11'),
(4, '669529340', 'Mahi Patel', 1, 0, '300', '80', '2024-03-22 01:25:45'),
(5, '531504111', 'Shahjahan', 1, 0, '300', '80', '2024-03-24 08:18:31'),
(6, '687510178', 'Aarushi', 1, 0, '1100', '800', '2024-03-24 08:26:51'),
(7, '662843134', 'Kavya', 1, 0, '300', '80', '2024-03-24 08:29:26'),
(8, '277046848', 'Monika Modi', 3, 1, '300', '80', '2024-03-25 06:07:00'),
(9, '112829894', 'Anand Modi', 4, 2, '300', '80', '2024-03-25 06:07:34'),
(10, '114920236', 'Dhruvi ', 2, 2, '300', '80', '2024-03-25 15:25:23'),
(11, '746238444', 'Dhruvi ', 2, 2, '300', '80', '2024-03-25 15:26:03');

-- --------------------------------------------------------

--
-- Table structure for table `tbltickettype`
--

CREATE TABLE `tbltickettype` (
  `ID` int(10) NOT NULL,
  `TicketType` varchar(200) DEFAULT NULL,
  `Price` varchar(50) DEFAULT NULL,
  `CreationDate` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `tbltickettype`
--

INSERT INTO `tbltickettype` (`ID`, `TicketType`, `Price`, `CreationDate`) VALUES
(1, 'Normal Adult', '300', '2024-02-16 01:12:56'),
(2, 'Normal Child', '80', '2024-02-16 01:12:56'),
(3, 'Foreigner Adult', '1100', '2024-02-16 01:12:56'),
(4, 'Foreigner Child', '800', '2024-02-16 01:12:56');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `animal_participation`
--
ALTER TABLE `animal_participation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `event_id FK` (`event_id`),
  ADD KEY `animal_id FK` (`animal_id`);

--
-- Indexes for table `diagnosis`
--
ALTER TABLE `diagnosis`
  ADD PRIMARY KEY (`diagnosis_id`),
  ADD KEY `animal_id` (`animal_id`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`employee_id`),
  ADD KEY `job_type` (`job_type`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`event_id`),
  ADD UNIQUE KEY `event_name` (`event_name`);

--
-- Indexes for table `expenditure`
--
ALTER TABLE `expenditure`
  ADD PRIMARY KEY (`expense_id`);

--
-- Indexes for table `food`
--
ALTER TABLE `food`
  ADD PRIMARY KEY (`food_id`),
  ADD KEY `supplier_id` (`supplier_id`) USING BTREE;

--
-- Indexes for table `health_status`
--
ALTER TABLE `health_status`
  ADD PRIMARY KEY (`health_id`),
  ADD KEY `animal_id` (`animal_id`),
  ADD KEY `animal_id_2` (`animal_id`),
  ADD KEY `health` (`health`) USING BTREE;

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `job`
--
ALTER TABLE `job`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `job_type` (`job_type`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `item_id` (`item_id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `revenue`
--
ALTER TABLE `revenue`
  ADD PRIMARY KEY (`revenue_id`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`supplier_id`);

--
-- Indexes for table `tbladmin`
--
ALTER TABLE `tbladmin`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `tblanimal`
--
ALTER TABLE `tblanimal`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `health_condition` (`health_condition`);

--
-- Indexes for table `tblpage`
--
ALTER TABLE `tblpage`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `tblticforeigner`
--
ALTER TABLE `tblticforeigner`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `TicketID` (`TicketID`),
  ADD KEY `TicketID_2` (`TicketID`),
  ADD KEY `priceid` (`AdultUnitprice`);

--
-- Indexes for table `tblticindian`
--
ALTER TABLE `tblticindian`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `TicketID` (`TicketID`),
  ADD KEY `pidddd` (`ChildUnitprice`);

--
-- Indexes for table `tbltickettype`
--
ALTER TABLE `tbltickettype`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `TicketType` (`TicketType`),
  ADD KEY `Price` (`Price`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `animal_participation`
--
ALTER TABLE `animal_participation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `diagnosis`
--
ALTER TABLE `diagnosis`
  MODIFY `diagnosis_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `employee`
--
ALTER TABLE `employee`
  MODIFY `employee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `expenditure`
--
ALTER TABLE `expenditure`
  MODIFY `expense_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `food`
--
ALTER TABLE `food`
  MODIFY `food_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `health_status`
--
ALTER TABLE `health_status`
  MODIFY `health_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `job`
--
ALTER TABLE `job`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `revenue`
--
ALTER TABLE `revenue`
  MODIFY `revenue_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `tbladmin`
--
ALTER TABLE `tbladmin`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tblanimal`
--
ALTER TABLE `tblanimal`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `tblpage`
--
ALTER TABLE `tblpage`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `tblticforeigner`
--
ALTER TABLE `tblticforeigner`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `tblticindian`
--
ALTER TABLE `tblticindian`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `tbltickettype`
--
ALTER TABLE `tbltickettype`
  MODIFY `ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `animal_participation`
--
ALTER TABLE `animal_participation`
  ADD CONSTRAINT `animal_participation_ibfk_1` FOREIGN KEY (`animal_id`) REFERENCES `tblanimal` (`ID`),
  ADD CONSTRAINT `animal_participation_ibfk_2` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`);

--
-- Constraints for table `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`job_type`) REFERENCES `job` (`job_type`);

--
-- Constraints for table `tblticforeigner`
--
ALTER TABLE `tblticforeigner`
  ADD CONSTRAINT `priceid` FOREIGN KEY (`AdultUnitprice`) REFERENCES `tbltickettype` (`Price`);

--
-- Constraints for table `tblticindian`
--
ALTER TABLE `tblticindian`
  ADD CONSTRAINT `pidddd` FOREIGN KEY (`ChildUnitprice`) REFERENCES `tbltickettype` (`Price`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
