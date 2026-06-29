CREATE DATABASE IF NOT EXISTS CommitVault;
USE CommitVault;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- ==========================================
-- 1. CLEANUP & DROP EXISTING OBJECTS
-- ==========================================
DROP VIEW IF EXISTS `account_summary_view`;
DROP VIEW IF EXISTS `Security_Failed_Transfers_View`;
DROP TABLE IF EXISTS `failed_transactions`;
DROP TABLE IF EXISTS `transactions`;
DROP TABLE IF EXISTS `audit_logs`;
DROP TABLE IF EXISTS `accounts`;
DROP TABLE IF EXISTS `customers`;
DROP PROCEDURE IF EXISTS `ProcessFundTransfer`;

-- ==========================================
-- 2. CORE SCHEMA TABLES
-- ==========================================

-- Table: customers
CREATE TABLE `customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `kyc_status` enum('Pending','Verified','Rejected') DEFAULT 'Pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone_number` (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table: accounts
CREATE TABLE `accounts` (
  `account_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `account_type` enum('Savings','Current','Salary') DEFAULT 'Savings',
  `balance` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` enum('Active','Dormant','Closed') DEFAULT 'Active',
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`account_id`),
  KEY `fk_customer` (`customer_id`),
  CONSTRAINT `fk_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE RESTRICT,
  CONSTRAINT `chk_positive_balance` CHECK ((`balance` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table: transactions
CREATE TABLE `transactions` (
  `transaction_id` varchar(36) NOT NULL,
  `account_id` int NOT NULL,
  `transaction_type` enum('Deposit','Withdrawal','Transfer_In','Transfer_Out') NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `transaction_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `fk_account` (`account_id`),
  CONSTRAINT `fk_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`account_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_positive_amount` CHECK ((`amount` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table: audit_logs
CREATE TABLE `audit_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `action_type` varchar(50) NOT NULL,
  `table_affected` varchar(50) NOT NULL,
  `action_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `details` text,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table: failed_transactions
CREATE TABLE `failed_transactions` (
    `log_id` int NOT NULL AUTO_INCREMENT,
    `sender_account_id` int NOT NULL,
    `receiver_account_id` int NOT NULL,
    `attempted_amount` decimal(15,2) NOT NULL,
    `failure_reason` varchar(255) NOT NULL,
    `attempt_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ==========================================
-- 3. SEED DATA POPULATION
-- ==========================================
LOCK TABLES `customers` WRITE;
INSERT INTO `customers` (`customer_id`, `first_name`, `last_name`, `email`, `phone_number`, `kyc_status`, `created_at`) VALUES 
(1,'Aarav','Sharma','aarav.s@gmail.com','+919876543210','Verified','2026-04-11 07:05:16'),
(2,'Priya','Patel','priya.p@yahoo.com','+919876543211','Verified','2026-04-11 07:05:16'),
(3,'Rohan','Verma','rohan.v@outlook.com','+919876543212','Pending','2026-04-11 07:05:16'),
(4,'Vikram', 'Singh', 'vikram.s@techcorp.in', '+919876500001', 'Verified', '2026-04-12 18:15:00'),
(5,'Ananya', 'Desai', 'ananya.d@university.edu', '+919876500002', 'Pending', '2026-04-12 18:15:00'),
(6,'Rahul', 'Kapoor', 'r.kapoor@startup.io', '+919876500003', 'Verified', '2026-04-12 18:15:00'),
(7,'Neha', 'Gupta', 'neha_sketchy@spam.com', '+919876500004', 'Rejected', '2026-04-12 18:15:00'),
(8,'Pooja', 'Iyer', 'pooja.wealth@investment.com', '+919876500005', 'Verified', '2026-04-12 18:15:00');
UNLOCK TABLES;

LOCK TABLES `accounts` WRITE;
INSERT INTO `accounts` (`account_id`, `customer_id`, `account_type`, `balance`, `status`, `last_updated`) VALUES 
(1,1,'Savings',15000.50,'Active','2026-04-11 07:05:31'),
(2,1,'Current',50000.00,'Active','2026-04-11 07:05:31'),
(3,2,'Savings',8500.75,'Active','2026-04-11 07:05:31'),
(4,3,'Salary',0.00,'Dormant','2026-04-11 07:05:31'),
(5,4,'Salary',125000.00,'Active','2026-04-12 18:19:58'),
(6,5,'Savings',1500.50,'Active','2026-04-12 18:19:58'),
(7,6,'Current',450000.00,'Active','2026-04-12 18:19:58'),
(8,7,'Savings',0.00,'Closed','2026-04-12 18:27:27'),
(9,8,'Savings',850000.00,'Active','2026-04-12 18:27:27'),
(10,8,'Current',25000.00,'Dormant','2026-04-12 18:27:27');
UNLOCK TABLES;

LOCK TABLES `transactions` WRITE;
INSERT INTO `transactions` (`transaction_id`, `account_id`, `transaction_type`, `amount`, `transaction_date`, `description`) VALUES 
('TXN-10001',1,'Deposit',5000.00,'2026-04-11 07:05:57','Initial Account Funding'),
('TXN-10002',2,'Deposit',20000.00,'2026-04-11 07:05:57','Business Revenue'),
('TXN-10003',1,'Withdrawal',1000.00,'2026-04-11 07:05:57','ATM Withdrawal'),
('TXN-10004',3,'Deposit',8500.75,'2026-04-11 07:05:57','Salary Credit');
UNLOCK TABLES;

-- ==========================================
-- 4. VIEWS (DATABASE LAYER DATA AGGREGATION)
-- ==========================================

-- View: account_summary_view
CREATE VIEW `account_summary_view` AS 
SELECT 
    `c`.`customer_id` AS `customer_id`,
    CONCAT(`c`.`first_name`, ' ', `c`.`last_name`) AS `full_name`,
    COUNT(`a`.`account_id`) AS `total_accounts`,
    IFNULL(SUM(`a`.`balance`), 0.00) AS `total_portfolio_balance`
FROM `customers` `c` 
LEFT JOIN `accounts` `a` ON `c`.`customer_id` = `a`.`customer_id`
GROUP BY `c`.`customer_id`, `c`.`first_name`, `c`.`last_name`;

-- View: Security_Failed_Transfers_View
CREATE VIEW `Security_Failed_Transfers_View` AS
SELECT 
    `f`.`attempt_date` AS `attempt_date`,
    CONCAT(`c`.`first_name`, ' ', `c`.`last_name`) AS `sender_name`,
    `f`.`sender_account_id` AS `sender_account_id`,
    `f`.`attempted_amount` AS `attempted_amount`,
    `f`.`failure_reason` AS `failure_reason`
FROM `failed_transactions` `f`
JOIN `accounts` `a` ON `f`.`sender_account_id` = `a`.`account_id`
JOIN `customers` `c` ON `a`.`customer_id` = `c`.`customer_id`;

-- ==========================================
-- 5. AUTOMATION ENGINES (TRIGGERS)
-- ==========================================
DELIMITER //

-- Trigger: after_account_creation
CREATE TRIGGER `after_account_creation` AFTER INSERT ON `accounts` FOR EACH ROW 
BEGIN
    INSERT INTO audit_logs (action_type, table_affected, details)
    VALUES ('INSERT', 'accounts', CONCAT('New account ', NEW.account_id, ' created for customer ', NEW.customer_id));
END//

-- Trigger: after_transaction_created
CREATE TRIGGER `after_transaction_created` AFTER INSERT ON `transactions` FOR EACH ROW 
BEGIN
    INSERT INTO audit_logs (action_type, table_affected, details)
    VALUES (NEW.transaction_type, 'transactions', CONCAT('Amount: ', NEW.amount, ' | Account ID: ', NEW.account_id, ' | Details: ', IFNULL(NEW.description, 'None')));
END//

DELIMITER ;

-- ==========================================
-- 6. TRANSACTION INTEGRITY RULES (PROCEDURES)
-- ==========================================
DELIMITER //

CREATE PROCEDURE `ProcessFundTransfer`(
    IN p_sender_id INT,
    IN p_receiver_id INT,
    IN p_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_sender_balance DECIMAL(10,2);
    DECLARE v_sender_exists INT;
    DECLARE v_receiver_exists INT;
    
    -- Instantiate transaction boundaries explicitly
    START TRANSACTION;
    
    -- Verify account validity first to gracefully avoid broken data states
    SELECT COUNT(*) INTO v_sender_exists FROM `accounts` WHERE `account_id` = p_sender_id;
    SELECT COUNT(*) INTO v_receiver_exists FROM `accounts` WHERE `account_id` = p_receiver_id;
    
    IF v_sender_exists = 0 OR v_receiver_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid sender or receiver account identifier';
    END IF;
    
    -- Implement clear row-level execution locks (FOR UPDATE) to prevent concurrency anomalies
    SELECT `balance` INTO v_sender_balance 
    FROM `accounts` 
    WHERE `account_id` = p_sender_id FOR UPDATE;
    
    -- Business Logic Ledger Evaluation
    IF v_sender_balance >= p_amount THEN
        -- Safely modify balances atomically
        UPDATE `accounts` 
        SET `balance` = `balance` - p_amount 
        WHERE `account_id` = p_sender_id;
        
        UPDATE `accounts` 
        SET `balance` = `balance` + p_amount 
        WHERE `account_id` = p_receiver_id;
        
        -- Append balancing accounting statements tracking standard 36-char strings via UUID()
        INSERT INTO `transactions` (`transaction_id`, `account_id`, `transaction_type`, `amount`, `description`)
        VALUES (UUID(), p_sender_id, 'Transfer_Out', p_amount, CONCAT('Transfer to Account ', p_receiver_id));
        
        INSERT INTO `transactions` (`transaction_id`, `account_id`, `transaction_type`, `amount`, `description`)
        VALUES (UUID(), p_receiver_id, 'Transfer_In', p_amount, CONCAT('Transfer from Account ', p_sender_id));
        
        -- Lock down changes permanently
        COMMIT;
    ELSE
        -- Rollback state tracking instantly
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance for transfer';
    END IF;
END //

DELIMITER ;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;