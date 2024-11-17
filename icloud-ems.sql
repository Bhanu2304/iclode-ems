-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 17, 2024 at 03:04 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `icloud-ems`
--

-- --------------------------------------------------------

--
-- Table structure for table `branches`
--

CREATE TABLE `branches` (
  `branch_id` int(11) NOT NULL,
  `branch_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `branch_feecollectiontypes`
--

CREATE TABLE `branch_feecollectiontypes` (
  `branch_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `branch_feetypes`
--

CREATE TABLE `branch_feetypes` (
  `branch_id` int(11) NOT NULL,
  `fee_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `commonfeecollection`
--

CREATE TABLE `commonfeecollection` (
  `collection_id` int(11) NOT NULL,
  `receipt_id` varchar(255) DEFAULT NULL,
  `total_amount` decimal(15,2) DEFAULT NULL,
  `entry_mode_id` int(11) DEFAULT NULL,
  `remarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `commonfeecollectionheadwise`
--

CREATE TABLE `commonfeecollectionheadwise` (
  `detail_id` int(11) NOT NULL,
  `collection_id` int(11) DEFAULT NULL,
  `fee_head_id` int(11) DEFAULT NULL,
  `paid_amount` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entrymode`
--

CREATE TABLE `entrymode` (
  `mode_id` int(11) NOT NULL,
  `mode_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `entrymode`
--

INSERT INTO `entrymode` (`mode_id`, `mode_name`) VALUES
(1, 'DUE'),
(2, 'REVDUE'),
(3, 'SCHOLARSHIP'),
(4, 'SCHOLARSHIPREV/REVCONCESSION'),
(5, 'CONCESSION'),
(6, 'RCPT'),
(7, 'REVRCPT'),
(8, 'JV'),
(9, 'REVJV'),
(10, 'PMT'),
(11, 'REVPMT'),
(12, 'Fundtransfer');

-- --------------------------------------------------------

--
-- Table structure for table `feecategory`
--

CREATE TABLE `feecategory` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feecollectiontypes`
--

CREATE TABLE `feecollectiontypes` (
  `type_id` int(11) NOT NULL,
  `type_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `feecollectiontypes`
--

INSERT INTO `feecollectiontypes` (`type_id`, `type_name`) VALUES
(1, 'academic'),
(2, 'academicmisc'),
(3, 'hostel'),
(4, 'hostelmisc'),
(5, 'transport'),
(6, 'transportmisc');

-- --------------------------------------------------------

--
-- Table structure for table `feetypes`
--

CREATE TABLE `feetypes` (
  `fee_id` int(11) NOT NULL,
  `fee_head` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `financialtran`
--

CREATE TABLE `financialtran` (
  `transaction_id` int(11) NOT NULL,
  `voucher_no` varchar(255) DEFAULT NULL,
  `total_amount` decimal(15,2) DEFAULT NULL,
  `entry_mode_id` int(11) DEFAULT NULL,
  `remarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `financialtrandetail`
--

CREATE TABLE `financialtrandetail` (
  `detail_id` int(11) NOT NULL,
  `transaction_id` int(11) DEFAULT NULL,
  `fee_head_id` int(11) DEFAULT NULL,
  `due_amount` decimal(15,2) DEFAULT NULL,
  `paid_amount` decimal(15,2) DEFAULT NULL,
  `concession_amount` decimal(15,2) DEFAULT NULL,
  `scholarship_amount` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `financial_trans`
--

CREATE TABLE `financial_trans` (
  `id` int(11) NOT NULL,
  `voucher_no` varchar(50) NOT NULL,
  `module_id` int(11) NOT NULL DEFAULT 1,
  `total_amount` decimal(18,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `financial_trans_details`
--

CREATE TABLE `financial_trans_details` (
  `id` int(11) NOT NULL,
  `financial_trans_id` int(11) NOT NULL,
  `fee_head` varchar(100) NOT NULL,
  `due_amount` decimal(18,2) DEFAULT 0.00,
  `paid_amount` decimal(18,2) DEFAULT 0.00,
  `concession_amount` decimal(18,2) DEFAULT 0.00,
  `scholarship_amount` decimal(18,2) DEFAULT 0.00,
  `refund_amount` decimal(18,2) DEFAULT 0.00,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `module`
--

CREATE TABLE `module` (
  `module_id` int(11) NOT NULL,
  `module_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `module`
--

INSERT INTO `module` (`module_id`, `module_name`) VALUES
(1, 'academic'),
(2, 'academicmisc'),
(3, 'hostel'),
(4, 'hostelmisc'),
(5, 'transport'),
(6, 'transportmisc');

-- --------------------------------------------------------

--
-- Table structure for table `temporary_completedata`
--

CREATE TABLE `temporary_completedata` (
  `id` int(11) NOT NULL,
  `Sr` int(11) DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `Academic_Year` varchar(20) DEFAULT NULL,
  `Session` varchar(20) DEFAULT NULL,
  `Alloted_Category` varchar(100) DEFAULT NULL,
  `Voucher_Type` varchar(50) DEFAULT NULL,
  `Voucher_No` varchar(50) DEFAULT NULL,
  `Roll_No` varchar(50) DEFAULT NULL,
  `Admno_UniqueId` varchar(50) DEFAULT NULL,
  `Status` varchar(20) DEFAULT NULL,
  `Fee_Category` varchar(100) DEFAULT NULL,
  `Faculty` varchar(100) DEFAULT NULL,
  `Program` varchar(100) DEFAULT NULL,
  `Department` varchar(100) DEFAULT NULL,
  `Batch` varchar(50) DEFAULT NULL,
  `Receipt_No` varchar(50) DEFAULT NULL,
  `Fee_Head` varchar(100) DEFAULT NULL,
  `Due_Amount` decimal(18,2) DEFAULT 0.00,
  `Paid_Amount` decimal(18,2) DEFAULT 0.00,
  `Concession_Amount` decimal(18,2) DEFAULT 0.00,
  `Scholarship_Amount` decimal(18,2) DEFAULT 0.00,
  `Reverse_Concession_Amount` decimal(18,2) DEFAULT 0.00,
  `Write_Off_Amount` decimal(18,2) DEFAULT 0.00,
  `Adjusted_Amount` decimal(18,2) DEFAULT 0.00,
  `Refund_Amount` decimal(18,2) DEFAULT 0.00,
  `Fund_TranCfer_Amount` decimal(18,2) DEFAULT 0.00,
  `Remarks` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `branches`
--
ALTER TABLE `branches`
  ADD PRIMARY KEY (`branch_id`);

--
-- Indexes for table `branch_feecollectiontypes`
--
ALTER TABLE `branch_feecollectiontypes`
  ADD PRIMARY KEY (`branch_id`,`type_id`),
  ADD KEY `type_id` (`type_id`);

--
-- Indexes for table `branch_feetypes`
--
ALTER TABLE `branch_feetypes`
  ADD PRIMARY KEY (`branch_id`,`fee_id`),
  ADD KEY `fee_id` (`fee_id`);

--
-- Indexes for table `commonfeecollection`
--
ALTER TABLE `commonfeecollection`
  ADD PRIMARY KEY (`collection_id`),
  ADD KEY `entry_mode_id` (`entry_mode_id`);

--
-- Indexes for table `commonfeecollectionheadwise`
--
ALTER TABLE `commonfeecollectionheadwise`
  ADD PRIMARY KEY (`detail_id`),
  ADD KEY `collection_id` (`collection_id`),
  ADD KEY `fee_head_id` (`fee_head_id`);

--
-- Indexes for table `entrymode`
--
ALTER TABLE `entrymode`
  ADD PRIMARY KEY (`mode_id`);

--
-- Indexes for table `feecategory`
--
ALTER TABLE `feecategory`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `feecollectiontypes`
--
ALTER TABLE `feecollectiontypes`
  ADD PRIMARY KEY (`type_id`);

--
-- Indexes for table `feetypes`
--
ALTER TABLE `feetypes`
  ADD PRIMARY KEY (`fee_id`);

--
-- Indexes for table `financialtran`
--
ALTER TABLE `financialtran`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `entry_mode_id` (`entry_mode_id`);

--
-- Indexes for table `financialtrandetail`
--
ALTER TABLE `financialtrandetail`
  ADD PRIMARY KEY (`detail_id`),
  ADD KEY `transaction_id` (`transaction_id`),
  ADD KEY `fee_head_id` (`fee_head_id`);

--
-- Indexes for table `financial_trans`
--
ALTER TABLE `financial_trans`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `financial_trans_details`
--
ALTER TABLE `financial_trans_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `financial_trans_id` (`financial_trans_id`);

--
-- Indexes for table `module`
--
ALTER TABLE `module`
  ADD PRIMARY KEY (`module_id`);

--
-- Indexes for table `temporary_completedata`
--
ALTER TABLE `temporary_completedata`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `branches`
--
ALTER TABLE `branches`
  MODIFY `branch_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `commonfeecollection`
--
ALTER TABLE `commonfeecollection`
  MODIFY `collection_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `commonfeecollectionheadwise`
--
ALTER TABLE `commonfeecollectionheadwise`
  MODIFY `detail_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `entrymode`
--
ALTER TABLE `entrymode`
  MODIFY `mode_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `feecategory`
--
ALTER TABLE `feecategory`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `feecollectiontypes`
--
ALTER TABLE `feecollectiontypes`
  MODIFY `type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `feetypes`
--
ALTER TABLE `feetypes`
  MODIFY `fee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT for table `financialtran`
--
ALTER TABLE `financialtran`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `financialtrandetail`
--
ALTER TABLE `financialtrandetail`
  MODIFY `detail_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `financial_trans`
--
ALTER TABLE `financial_trans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `financial_trans_details`
--
ALTER TABLE `financial_trans_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `module`
--
ALTER TABLE `module`
  MODIFY `module_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `temporary_completedata`
--
ALTER TABLE `temporary_completedata`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `branch_feecollectiontypes`
--
ALTER TABLE `branch_feecollectiontypes`
  ADD CONSTRAINT `branch_feecollectiontypes_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`branch_id`),
  ADD CONSTRAINT `branch_feecollectiontypes_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `feecollectiontypes` (`type_id`);

--
-- Constraints for table `branch_feetypes`
--
ALTER TABLE `branch_feetypes`
  ADD CONSTRAINT `branch_feetypes_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`branch_id`),
  ADD CONSTRAINT `branch_feetypes_ibfk_2` FOREIGN KEY (`fee_id`) REFERENCES `feetypes` (`fee_id`);

--
-- Constraints for table `commonfeecollection`
--
ALTER TABLE `commonfeecollection`
  ADD CONSTRAINT `commonfeecollection_ibfk_1` FOREIGN KEY (`entry_mode_id`) REFERENCES `entrymode` (`mode_id`);

--
-- Constraints for table `commonfeecollectionheadwise`
--
ALTER TABLE `commonfeecollectionheadwise`
  ADD CONSTRAINT `commonfeecollectionheadwise_ibfk_1` FOREIGN KEY (`collection_id`) REFERENCES `commonfeecollection` (`collection_id`),
  ADD CONSTRAINT `commonfeecollectionheadwise_ibfk_2` FOREIGN KEY (`fee_head_id`) REFERENCES `feetypes` (`fee_id`);

--
-- Constraints for table `financialtran`
--
ALTER TABLE `financialtran`
  ADD CONSTRAINT `financialtran_ibfk_1` FOREIGN KEY (`entry_mode_id`) REFERENCES `entrymode` (`mode_id`);

--
-- Constraints for table `financialtrandetail`
--
ALTER TABLE `financialtrandetail`
  ADD CONSTRAINT `financialtrandetail_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `financialtran` (`transaction_id`),
  ADD CONSTRAINT `financialtrandetail_ibfk_2` FOREIGN KEY (`fee_head_id`) REFERENCES `feetypes` (`fee_id`);

--
-- Constraints for table `financial_trans_details`
--
ALTER TABLE `financial_trans_details`
  ADD CONSTRAINT `financial_trans_details_ibfk_1` FOREIGN KEY (`financial_trans_id`) REFERENCES `financial_trans` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
