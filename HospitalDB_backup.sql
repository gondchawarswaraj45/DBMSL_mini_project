-- MySQL dump 10.13  Distrib 8.4.6, for Linux (x86_64)
--
-- Host: localhost    Database: HospitalDB
-- ------------------------------------------------------
-- Server version	8.4.6-0ubuntu0.25.04.3

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

--
-- Table structure for table `Admission`
--

DROP TABLE IF EXISTS `Admission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Admission` (
  `admission_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `room_id` int NOT NULL,
  `admission_date` date NOT NULL,
  `relative_name` varchar(100) DEFAULT NULL,
  `relative_contact` varchar(15) DEFAULT NULL,
  `relative_address` text,
  `patient_address` text,
  `discharge_date` date DEFAULT NULL,
  `doctor_id` int DEFAULT NULL,
  PRIMARY KEY (`admission_id`),
  KEY `patient_id` (`patient_id`),
  KEY `room_id` (`room_id`),
  KEY `doctor_id` (`doctor_id`),
  CONSTRAINT `Admission_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `Patient` (`patient_id`),
  CONSTRAINT `Admission_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `Room` (`room_id`),
  CONSTRAINT `Admission_ibfk_3` FOREIGN KEY (`doctor_id`) REFERENCES `Doctor` (`doctor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Admission`
--

LOCK TABLES `Admission` WRITE;
/*!40000 ALTER TABLE `Admission` DISABLE KEYS */;
INSERT INTO `Admission` VALUES (5,11,14,'2025-10-08','Sagar Patil','8569252554','warje , pune','narhe , pune',NULL,NULL),(6,2,15,'2025-10-08','sameer','9546876803','pune','pune\r\n',NULL,2);
/*!40000 ALTER TABLE `Admission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Appointment`
--

DROP TABLE IF EXISTS `Appointment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Appointment` (
  `appointment_id` int NOT NULL AUTO_INCREMENT,
  `appointment_date` date DEFAULT NULL,
  `time_slot` varchar(20) DEFAULT NULL,
  `patient_id` int DEFAULT NULL,
  `doctor_id` int DEFAULT NULL,
  PRIMARY KEY (`appointment_id`),
  KEY `patient_id` (`patient_id`),
  KEY `doctor_id` (`doctor_id`),
  CONSTRAINT `Appointment_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `Patient` (`patient_id`),
  CONSTRAINT `Appointment_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `Doctor` (`doctor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Appointment`
--

LOCK TABLES `Appointment` WRITE;
/*!40000 ALTER TABLE `Appointment` DISABLE KEYS */;
INSERT INTO `Appointment` VALUES (1,'2025-10-05','10:00 AM',1,1),(2,'2025-10-06','11:30 AM',2,2),(3,'2025-10-04','11:00 am',1,5),(4,'2025-10-13','11:30',1,1);
/*!40000 ALTER TABLE `Appointment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Billing`
--

DROP TABLE IF EXISTS `Billing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Billing` (
  `bill_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int DEFAULT NULL,
  `doctor_charge` decimal(10,2) DEFAULT NULL,
  `room_charge` decimal(10,2) DEFAULT NULL,
  `medicine_charge` decimal(10,2) DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`bill_id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `Billing_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `Patient` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Billing`
--

LOCK TABLES `Billing` WRITE;
/*!40000 ALTER TABLE `Billing` DISABLE KEYS */;
INSERT INTO `Billing` VALUES (1,1,1500.00,2000.00,500.00,4000.00,'Unpaid'),(2,2,2000.00,0.00,300.00,2300.00,'Paid');
/*!40000 ALTER TABLE `Billing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Billing_Medicine`
--

DROP TABLE IF EXISTS `Billing_Medicine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Billing_Medicine` (
  `bill_id` int NOT NULL,
  `medicine_id` int NOT NULL,
  `quantity` int DEFAULT NULL,
  PRIMARY KEY (`bill_id`,`medicine_id`),
  KEY `medicine_id` (`medicine_id`),
  CONSTRAINT `Billing_Medicine_ibfk_1` FOREIGN KEY (`bill_id`) REFERENCES `Billing` (`bill_id`),
  CONSTRAINT `Billing_Medicine_ibfk_2` FOREIGN KEY (`medicine_id`) REFERENCES `Medicine` (`medicine_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Billing_Medicine`
--

LOCK TABLES `Billing_Medicine` WRITE;
/*!40000 ALTER TABLE `Billing_Medicine` DISABLE KEYS */;
INSERT INTO `Billing_Medicine` VALUES (1,1,10),(1,2,20),(2,3,5);
/*!40000 ALTER TABLE `Billing_Medicine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Department`
--

DROP TABLE IF EXISTS `Department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Department` (
  `department_id` int NOT NULL AUTO_INCREMENT,
  `dept_name` varchar(50) NOT NULL,
  `location` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Department`
--

LOCK TABLES `Department` WRITE;
/*!40000 ALTER TABLE `Department` DISABLE KEYS */;
INSERT INTO `Department` VALUES (1,'Cardiology','Block A'),(2,'Neurology','Block B'),(3,'Orthopedics','Block C'),(4,'Pediatrics','Block D'),(5,'Cardiology','Block A'),(6,'Neurology','Block B'),(7,'Cardiology',NULL),(8,'Neurology',NULL),(9,'Orthopedics',NULL),(10,'Pediatrics',NULL),(11,'General Medicine',NULL),(12,'Dermatology',NULL),(13,'ENT',NULL),(14,'Oncology',NULL),(15,'Urology',NULL),(16,'Gynecology',NULL),(17,'Cardiology',NULL),(18,'Neurology',NULL),(19,'Orthopedics',NULL),(20,'Pediatrics',NULL),(21,'General Medicine',NULL),(22,'Dermatology',NULL),(23,'ENT',NULL),(24,'Oncology',NULL),(25,'Urology',NULL),(26,'Gynecology',NULL),(27,'General Medicine',NULL),(28,'General Surgery',NULL),(29,'Cardiology',NULL),(30,'Neurology',NULL),(31,'Neurosurgery',NULL),(32,'Orthopaedics',NULL),(33,'Pediatrics',NULL),(34,'Obstetrics & Gynecology',NULL),(35,'Dermatology',NULL),(36,'Psychiatry',NULL),(37,'ENT',NULL),(38,'Ophthalmology',NULL),(39,'Anesthesiology',NULL),(40,'Radiology',NULL),(41,'Pathology',NULL),(42,'Oncology',NULL),(43,'Nephrology',NULL),(44,'Urology',NULL),(45,'Gastroenterology',NULL),(46,'Pulmonology',NULL),(47,'Endocrinology',NULL),(48,'Rheumatology',NULL),(49,'Hematology',NULL),(50,'Infectious Diseases',NULL),(51,'Geriatrics',NULL),(52,'Plastic Surgery',NULL),(53,'Pediatric Surgery',NULL),(54,'CTVS',NULL),(55,'Critical Care',NULL),(56,'Emergency Medicine',NULL),(57,'Family Medicine',NULL),(58,'Sports Medicine',NULL),(59,'Rehabilitation',NULL),(60,'Dentistry',NULL),(61,'Forensic Medicine',NULL),(62,'Nuclear Medicine',NULL);
/*!40000 ALTER TABLE `Department` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Discharge`
--

DROP TABLE IF EXISTS `Discharge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Discharge` (
  `discharge_id` int NOT NULL AUTO_INCREMENT,
  `admission_id` int NOT NULL,
  `discharge_date` date NOT NULL,
  `doctor_fees` decimal(10,2) DEFAULT '0.00',
  `room_charges` decimal(10,2) DEFAULT '0.00',
  `medicine_charges` decimal(10,2) DEFAULT '0.00',
  `total_bill` decimal(10,2) GENERATED ALWAYS AS (((`doctor_fees` + `room_charges`) + `medicine_charges`)) STORED,
  `payment_status` enum('Pending','Paid') DEFAULT 'Pending',
  PRIMARY KEY (`discharge_id`),
  KEY `admission_id` (`admission_id`),
  CONSTRAINT `Discharge_ibfk_1` FOREIGN KEY (`admission_id`) REFERENCES `Admission` (`admission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Discharge`
--

LOCK TABLES `Discharge` WRITE;
/*!40000 ALTER TABLE `Discharge` DISABLE KEYS */;
/*!40000 ALTER TABLE `Discharge` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DiseaseMaster`
--

DROP TABLE IF EXISTS `DiseaseMaster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DiseaseMaster` (
  `disease_id` int NOT NULL AUTO_INCREMENT,
  `disease_name` varchar(100) NOT NULL,
  PRIMARY KEY (`disease_id`),
  UNIQUE KEY `disease_name` (`disease_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DiseaseMaster`
--

LOCK TABLES `DiseaseMaster` WRITE;
/*!40000 ALTER TABLE `DiseaseMaster` DISABLE KEYS */;
INSERT INTO `DiseaseMaster` VALUES (5,'Arthritis'),(3,'Asthma'),(4,'Covid-19'),(1,'Diabetes'),(2,'Hypertension');
/*!40000 ALTER TABLE `DiseaseMaster` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Doctor`
--

DROP TABLE IF EXISTS `Doctor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Doctor` (
  `doctor_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `specialization` varchar(200) DEFAULT NULL,
  `contact_no` varchar(200) DEFAULT NULL,
  `fees` decimal(10,2) DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  PRIMARY KEY (`doctor_id`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `Doctor_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `Department` (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Doctor`
--

LOCK TABLES `Doctor` WRITE;
/*!40000 ALTER TABLE `Doctor` DISABLE KEYS */;
INSERT INTO `Doctor` VALUES (1,'Dr. Mehta','Cardiologist','9876543210',1500.00,1),(2,'Dr. Sharma','Neurologist','9876501234',2000.00,2),(3,'Dr. Reddy','Orthopedic','9123456780',1000.00,3),(4,'Dr. Patel','Pediatrician','9988776655',800.00,4),(5,'Mayur ','Cardiologist','9784212684',1000.00,1),(6,'Dr. Ram','Neurologist','9825646535',1500.00,6),(7,'Amit Kute','','9872867542, 7878745415',900.00,19),(55,'Dr. A.K. Sharma','General Medicine (MBBS, MD)','9876501234',800.00,1),(56,'Dr. Meena Patil','General Medicine (MBBS, MD, DNB)','9876502234',900.00,1),(57,'Dr. Ramesh Deshmukh','General Surgery (MBBS, MS)','9876503234',1000.00,2),(58,'Dr. N. Kulkarni','General Surgery (MBBS, MS, DNB)','9876504234',950.00,2),(59,'Dr. Vivek Joshi','Cardiology (MBBS, MD, DM)','9876505234',1500.00,3),(60,'Dr. Priya Chavan','Cardiology (MBBS, MD, DM)','9876506234',1600.00,3),(61,'Dr. Rahul More','Neurology (MBBS, MD, DM)','9876507234',1400.00,4),(62,'Dr. Sneha Rao','Neurology (MBBS, MD, DM)','9876508234',1450.00,4),(63,'Dr. Akash Tiwari','Neurosurgery (MBBS, MS, MCh)','9876509234',1800.00,5),(64,'Dr. Sanjay Bhagat','Orthopaedics (MBBS, MS)','9876510234',1200.00,6),(65,'Dr. Kavita Borkar','Orthopaedics (MBBS, MS, DNB)','9876511234',1250.00,6),(66,'Dr. Rajesh Naik','Pediatrics (MBBS, MD)','9876512234',900.00,7),(67,'Dr. Pooja Gokhale','Pediatrics (MBBS, MD)','9876513234',950.00,7),(68,'Dr. Nita Desai','OBGYN (MBBS, MD, DNB)','9876514234',1300.00,8),(69,'Dr. Rohit Malhotra','OBGYN (MBBS, MS)','9876515234',1200.00,8),(70,'Dr. Snehal Jadhav','Dermatology (MBBS, MD)','9876516234',1100.00,9),(71,'Dr. Pradeep Pawar','Dermatology (MBBS, MD)','9876517234',1050.00,9),(72,'Dr. Manish Khanna','Psychiatry (MBBS, MD)','9876518234',950.00,10),(73,'Dr. Richa Menon','ENT (MBBS, MS)','9876519234',1150.00,11),(74,'Dr. Vikas Patwardhan','ENT (MBBS, MS, DNB)','9876520234',1200.00,11),(75,'Dr. Anjali Iyer','Ophthalmology (MBBS, MS)','9876521234',1250.00,12),(76,'Dr. Ajay Kale','Ophthalmology (MBBS, MS)','9876522234',1300.00,12),(77,'Dr. Deepak Soni','Anesthesiology (MBBS, MD)','9876523234',1000.00,13),(78,'Dr. Rutuja Sawant','Radiology (MBBS, MD)','9876524234',1300.00,14),(79,'Dr. Harsha Vora','Pathology (MBBS, MD)','9876525234',900.00,15),(80,'Dr. Smita Rao','Oncology (MBBS, MD, DM)','9876526234',1600.00,16),(81,'Dr. Nitin Patil','Oncology (MBBS, MD, DM)','9876527234',1650.00,16),(82,'Dr. Rekha Sane','Nephrology (MBBS, MD, DM)','9876528234',1400.00,17),(83,'Dr. Ajinkya Patkar','Urology (MBBS, MS, MCh)','9876529234',1500.00,18),(84,'Dr. Shreya Joshi','Gastroenterology (MBBS, MD, DM)','9876530234',1450.00,19),(85,'Dr. Mahesh Dandekar','Pulmonology (MBBS, MD)','9876531234',1250.00,20),(86,'Dr. Vinod Kulkarni','Endocrinology (MBBS, MD, DM)','9876532234',1500.00,21),(87,'Dr. Radha Kamat','Rheumatology (MBBS, MD, DM)','9876533234',1350.00,22),(88,'Dr. Nisha Bhave','Hematology (MBBS, MD, DM)','9876534234',1400.00,23),(89,'Dr. Akansha Jain','Infectious Diseases (MBBS, MD, DM)','9876535234',1300.00,24),(90,'Dr. Vijay Rane','Geriatrics (MBBS, MD)','9876536234',1200.00,25),(91,'Dr. Aarti Kaur','Plastic & Reconstructive Surgery (MBBS, MS, MCh)','9876537234',1800.00,26),(92,'Dr. Pankaj Tamhane','Pediatric Surgery (MBBS, MS, MCh)','9876538234',1700.00,27),(93,'Dr. Shantanu Raut','Cardiothoracic Surgery (MBBS, MS, MCh)','9876539234',1900.00,28),(94,'Dr. Gaurav Dixit','Critical Care Medicine (MBBS, MD, DM)','9876540234',1400.00,29),(95,'Dr. Komal More','Emergency Medicine (MBBS, MD)','9876541234',1000.00,30),(96,'Dr. Suresh Iyer','Family Medicine (MBBS, MD)','9876542234',950.00,31),(97,'Dr. Tanmay Shetty','Sports Medicine (MBBS, MD)','9876543234',1250.00,32),(98,'Dr. Savita Bansal','Physical Medicine & Rehabilitation (MBBS, MD)','9876544234',1150.00,33),(99,'Dr. Kiran Jain','Dentistry (BDS, MDS)','9876545234',800.00,34),(100,'Dr. Lata Gokhale','Forensic Medicine (MBBS, MD)','9876546234',900.00,35),(101,'Dr. Neel Patwardhan','Nuclear Medicine (MBBS, MD)','9876547234',1500.00,36);
/*!40000 ALTER TABLE `Doctor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DoctorSchedule`
--

DROP TABLE IF EXISTS `DoctorSchedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DoctorSchedule` (
  `schedule_id` int NOT NULL AUTO_INCREMENT,
  `doctor_id` int NOT NULL,
  `day_of_week` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  PRIMARY KEY (`schedule_id`),
  KEY `doctor_id` (`doctor_id`),
  CONSTRAINT `DoctorSchedule_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `Doctor` (`doctor_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DoctorSchedule`
--

LOCK TABLES `DoctorSchedule` WRITE;
/*!40000 ALTER TABLE `DoctorSchedule` DISABLE KEYS */;
INSERT INTO `DoctorSchedule` VALUES (1,1,'Monday','10:00:00','15:00:00'),(2,1,'Tuesday','09:00:00','15:00:00');
/*!40000 ALTER TABLE `DoctorSchedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Medicine`
--

DROP TABLE IF EXISTS `Medicine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Medicine` (
  `medicine_id` int NOT NULL AUTO_INCREMENT,
  `medicine_name` varchar(50) NOT NULL,
  `manufacturer` varchar(50) DEFAULT NULL,
  `price_per_unit` decimal(10,2) DEFAULT NULL,
  `stock` int DEFAULT NULL,
  PRIMARY KEY (`medicine_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Medicine`
--

LOCK TABLES `Medicine` WRITE;
/*!40000 ALTER TABLE `Medicine` DISABLE KEYS */;
INSERT INTO `Medicine` VALUES (1,'Aspirin','Pharma Inc',10.00,100),(2,'Paracetamol','Medico Labs',5.00,200),(3,'Amoxicillin','HealthCare Ltd',15.00,150),(4,' Cyclopam ','Indoco Remedies Ltd.',40.00,120),(5,'ABZ','Indoco Remedies Ltd.',5.00,15);
/*!40000 ALTER TABLE `Medicine` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Patient`
--

DROP TABLE IF EXISTS `Patient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Patient` (
  `patient_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `age` int DEFAULT NULL,
  `gender` varchar(10) DEFAULT NULL,
  `contact_no` varchar(200) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `disease` varchar(200) DEFAULT NULL,
  `admit_date` date DEFAULT NULL,
  `discharge_date` date DEFAULT NULL,
  `doctor_id` int DEFAULT NULL,
  `room_id` int DEFAULT NULL,
  PRIMARY KEY (`patient_id`),
  KEY `doctor_id` (`doctor_id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `Patient_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `Doctor` (`doctor_id`),
  CONSTRAINT `Patient_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `Room` (`room_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Patient`
--

LOCK TABLES `Patient` WRITE;
/*!40000 ALTER TABLE `Patient` DISABLE KEYS */;
INSERT INTO `Patient` VALUES (1,'Rahul Verma',35,'Male','9876541111','Pune','Heart Problem','2025-10-01',NULL,1,NULL),(2,'Sneha Kulkarni',22,'Female','9876542222','Mumbai','Migraine','2025-10-02',NULL,2,15),(11,'Ravi Patil',32,'Male','9876543210',NULL,'Fever',NULL,NULL,1,14),(12,'Anita Joshi',45,'Female','9823456789',NULL,'Diabetes',NULL,NULL,2,NULL),(13,'Karan Mehta',28,'Male','9812345678',NULL,'Migraine',NULL,NULL,3,NULL),(14,'Priya Deshmukh',52,'Female','9801122334',NULL,'Hypertension',NULL,NULL,4,NULL);
/*!40000 ALTER TABLE `Patient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Room`
--

DROP TABLE IF EXISTS `Room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Room` (
  `room_id` int NOT NULL AUTO_INCREMENT,
  `room_number` varchar(20) DEFAULT NULL,
  `room_type` varchar(30) DEFAULT NULL,
  `charges_per_day` decimal(10,2) DEFAULT NULL,
  `bed_count` int DEFAULT '0',
  `availability` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`room_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Room`
--

LOCK TABLES `Room` WRITE;
/*!40000 ALTER TABLE `Room` DISABLE KEYS */;
INSERT INTO `Room` VALUES (1,'GW-01','General Ward',500.00,8,1),(2,'GW-02','General Ward',500.00,8,1),(3,'GW-03','General Ward',500.00,8,1),(4,'GW-04','General Ward',500.00,8,1),(5,'ICU-01','ICU',5000.00,1,1),(6,'ICU-02','ICU',5000.00,1,1),(7,'ICU-03','ICU',5000.00,1,1),(8,'ICU-04','ICU',5000.00,1,1),(9,'ICU-05','ICU',5000.00,1,1),(10,'ICU-06','ICU',5000.00,1,1),(11,'ICU-07','ICU',5000.00,1,1),(12,'ER-01','Emergency Ward',3000.00,1,1),(13,'ER-02','Emergency Ward',3000.00,1,1),(14,'PR-01','Private Room',2500.00,1,0),(15,'PR-02','Private Room',2500.00,1,0),(16,'PR-03','Private Room',2500.00,1,1),(17,'PR-04','Private Room',2500.00,1,1),(18,'PR-05','Private Room',2500.00,1,1),(19,'PR-06','Private Room',2500.00,1,1),(20,'PR-07','Private Room',2500.00,1,1),(21,'PR-08','Private Room',2500.00,1,1),(22,'PR-09','Private Room',2500.00,1,1),(23,'PR-10','Private Room',2500.00,1,1);
/*!40000 ALTER TABLE `Room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RoomBed`
--

DROP TABLE IF EXISTS `RoomBed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RoomBed` (
  `bed_id` int NOT NULL AUTO_INCREMENT,
  `room_id` int NOT NULL,
  `bed_label` varchar(50) NOT NULL,
  `bed_number` int NOT NULL,
  `occupied_by` int DEFAULT NULL,
  `availability` enum('Available','Occupied') DEFAULT 'Available',
  PRIMARY KEY (`bed_id`),
  KEY `room_id` (`room_id`),
  KEY `occupied_by` (`occupied_by`),
  CONSTRAINT `RoomBed_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `Room` (`room_id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RoomBed`
--

LOCK TABLES `RoomBed` WRITE;
/*!40000 ALTER TABLE `RoomBed` DISABLE KEYS */;
INSERT INTO `RoomBed` VALUES (1,1,'GW-01-B01',1,NULL,'Available'),(2,1,'GW-01-B02',2,NULL,'Available'),(3,1,'GW-01-B03',3,NULL,'Available'),(4,1,'GW-01-B04',4,NULL,'Available'),(5,1,'GW-01-B05',5,NULL,'Available'),(6,1,'GW-01-B06',6,NULL,'Available'),(7,1,'GW-01-B07',7,NULL,'Available'),(8,1,'GW-01-B08',8,NULL,'Available'),(9,2,'GW-02-B01',1,NULL,'Available'),(10,2,'GW-02-B02',2,NULL,'Available'),(11,2,'GW-02-B03',3,NULL,'Available'),(12,2,'GW-02-B04',4,NULL,'Available'),(13,2,'GW-02-B05',5,NULL,'Available'),(14,2,'GW-02-B06',6,NULL,'Available'),(15,2,'GW-02-B07',7,NULL,'Available'),(16,2,'GW-02-B08',8,NULL,'Available'),(17,3,'GW-03-B01',1,NULL,'Available'),(18,3,'GW-03-B02',2,NULL,'Available'),(19,3,'GW-03-B03',3,NULL,'Available'),(20,3,'GW-03-B04',4,NULL,'Available'),(21,3,'GW-03-B05',5,NULL,'Available'),(22,3,'GW-03-B06',6,NULL,'Available'),(23,3,'GW-03-B07',7,NULL,'Available'),(24,3,'GW-03-B08',8,NULL,'Available'),(25,4,'GW-04-B01',1,NULL,'Available'),(26,4,'GW-04-B02',2,NULL,'Available'),(27,4,'GW-04-B03',3,NULL,'Available'),(28,4,'GW-04-B04',4,NULL,'Available'),(29,4,'GW-04-B05',5,NULL,'Available'),(30,4,'GW-04-B06',6,NULL,'Available'),(31,4,'GW-04-B07',7,NULL,'Available'),(32,4,'GW-04-B08',8,NULL,'Available');
/*!40000 ALTER TABLE `RoomBed` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Specialization`
--

DROP TABLE IF EXISTS `Specialization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Specialization` (
  `specialization_id` int NOT NULL AUTO_INCREMENT,
  `specialization_name` varchar(100) NOT NULL,
  PRIMARY KEY (`specialization_id`),
  UNIQUE KEY `specialization_name` (`specialization_name`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Specialization`
--

LOCK TABLES `Specialization` WRITE;
/*!40000 ALTER TABLE `Specialization` DISABLE KEYS */;
INSERT INTO `Specialization` VALUES (13,'Anesthesiology'),(3,'Cardiology'),(28,'Cardiothoracic & Vascular Surgery'),(29,'Critical Care Medicine'),(34,'Dentistry'),(9,'Dermatology'),(30,'Emergency Medicine'),(21,'Endocrinology'),(11,'ENT (Otorhinolaryngology)'),(31,'Family Medicine'),(35,'Forensic Medicine'),(19,'Gastroenterology'),(1,'General Medicine'),(2,'General Surgery'),(25,'Geriatrics'),(23,'Hematology'),(24,'Infectious Diseases'),(17,'Nephrology'),(4,'Neurology'),(5,'Neurosurgery'),(36,'Nuclear Medicine'),(8,'Obstetrics & Gynecology'),(16,'Oncology'),(12,'Ophthalmology'),(6,'Orthopaedics'),(15,'Pathology'),(27,'Pediatric Surgery'),(7,'Pediatrics'),(33,'Physical Medicine & Rehabilitation'),(26,'Plastic & Reconstructive Surgery'),(10,'Psychiatry'),(20,'Pulmonology'),(14,'Radiology'),(22,'Rheumatology'),(32,'Sports Medicine'),(18,'Urology');
/*!40000 ALTER TABLE `Specialization` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SpecializationMaster`
--

DROP TABLE IF EXISTS `SpecializationMaster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SpecializationMaster` (
  `specialization_id` int NOT NULL AUTO_INCREMENT,
  `specialization_name` varchar(100) NOT NULL,
  PRIMARY KEY (`specialization_id`),
  UNIQUE KEY `specialization_name` (`specialization_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SpecializationMaster`
--

LOCK TABLES `SpecializationMaster` WRITE;
/*!40000 ALTER TABLE `SpecializationMaster` DISABLE KEYS */;
INSERT INTO `SpecializationMaster` VALUES (1,'Cardiology'),(5,'Dermatology'),(2,'Neurology'),(3,'Orthopedics'),(4,'Pediatrics');
/*!40000 ALTER TABLE `SpecializationMaster` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','doctor','patient') NOT NULL,
  `linked_id` int DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Users`
--

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
INSERT INTO `Users` VALUES (1,'swaraj','S123','admin',NULL),(2,'doctors','doctor123','doctor',1),(3,'admin','pbkdf2:sha256:600000$abcXYZ$89f0a7f...','admin',NULL),(5,'dr_mehta','doctor123','doctor',1),(6,'dr_sharma','doctor123','doctor',2),(7,'dr_reddy','doctor123','doctor',3),(8,'dr_patel','doctor123','doctor',4),(9,'mayur','doctor123','doctor',5),(10,'dr_ram','doctor123','doctor',6),(11,'amit_kute','doctor123','doctor',7),(12,'rahul_verma','patient123','patient',1),(13,'sneha_kulkarni','patient123','patient',2),(14,'ravi_patil','patient123','patient',11),(15,'anita_joshi','patient123','patient',12),(16,'karan_mehta','patient123','patient',13),(17,'priya_deshmukh','patient123','patient',14);
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-12 21:19:41
