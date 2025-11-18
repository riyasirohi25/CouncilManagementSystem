-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: council_db
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin_notifications`
--

DROP TABLE IF EXISTS `admin_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `message` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_notifications`
--

LOCK TABLES `admin_notifications` WRITE;
/*!40000 ALTER TABLE `admin_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `application_table`
--

DROP TABLE IF EXISTS `application_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application_table` (
  `applicationID` int NOT NULL AUTO_INCREMENT,
  `firstname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gender` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `house` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emailid` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `class` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position1` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position2` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position3` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `achievement` text COLLATE utf8mb4_unicode_ci,
  `reflection` text COLLATE utf8mb4_unicode_ci,
  `status` enum('Pending','Approved','Rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `session` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dateSubmission` date DEFAULT NULL,
  `timeSubmission` time DEFAULT NULL,
  `electionType` enum('Student','Teacher') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastEditedDate` date DEFAULT NULL,
  `lastEditedTime` time DEFAULT NULL,
  PRIMARY KEY (`applicationID`),
  KEY `emailid` (`emailid`),
  CONSTRAINT `application_table_ibfk_1` FOREIGN KEY (`emailid`) REFERENCES `login_table` (`emailid`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_table`
--

LOCK TABLES `application_table` WRITE;
/*!40000 ALTER TABLE `application_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `application_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `council_events`
--

DROP TABLE IF EXISTS `council_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `council_events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `event_date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `venue` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_visible` tinyint(1) NOT NULL DEFAULT '1',
  `created_by_email` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by_role` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_council_events_date` (`event_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `council_events`
--

LOCK TABLES `council_events` WRITE;
/*!40000 ALTER TABLE `council_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `council_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `interview_table`
--

DROP TABLE IF EXISTS `interview_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interview_table` (
  `applicationID` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `post` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` date DEFAULT NULL,
  `confirmed_time` time DEFAULT NULL,
  `venue` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `time1` time DEFAULT NULL,
  `time2` time DEFAULT NULL,
  `time3` time DEFAULT NULL,
  PRIMARY KEY (`applicationID`),
  UNIQUE KEY `unique_confirmed_slot` (`post`,`date`,`confirmed_time`),
  CONSTRAINT `interview_table_ibfk_1` FOREIGN KEY (`applicationID`) REFERENCES `application_table` (`applicationID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `interview_table`
--

LOCK TABLES `interview_table` WRITE;
/*!40000 ALTER TABLE `interview_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `interview_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_table`
--

DROP TABLE IF EXISTS `login_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_table` (
  `firstname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastname` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emailid` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('Admin','Student') COLLATE utf8mb4_unicode_ci NOT NULL,
  `isVerified` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`emailid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_table`
--

LOCK TABLES `login_table` WRITE;
/*!40000 ALTER TABLE `login_table` DISABLE KEYS */;
INSERT INTO `login_table` VALUES ('AAA','BBB','a@gmail.com','A@123456','Admin',1),('Aditya Singh','Shekhawat','adityashek@gmail.com','aditya@123','Student',1),('Admin','1111','admin@example.com','admin123','Admin',1),('admin','two','admin2@gmail.com','admin@12345','Admin',1),('Admin','Test','admintest@gmail.com','admin@123','Admin',1),('Aeshna','Singh','aeshnasingh@gmail.com','aeshna@123','Student',1),('ajay','singh','ajaysingh@gmail.com','ajay@123','Admin',1),('manisha','singh','manisha@gmail.com','manisha@123','Student',1),('manish','singh','manishsingh@gmail.com','manish@1234','Admin',1),('neha','patel','nehapatel@gmail.com','neha','Student',1),('Priyanka','Chaudhary','priyanka@gmail.com','priyanka123','Admin',1),('priyanka','chaudhary','priyanka15@gmail.com','Priyanka12@3','Admin',1),('ramneet','kaur','ramneetkaur@gmail.com','ramneet@123','Student',1),('riya','sirohi','riyasirohi@gmail.com','ro25@04se','Student',1),('Riya','Sirohi','riyasirohi25@gmail.com','riya@123','Admin',1),('Riya','Sirohi','riyasirohi250405@gmail.com','ro2504se','Admin',1),('rose','sirohi','rose@gmail.com','rose2405','Student',1),('rose','chen','rosechen@gmail.com','rosechen@123','Student',1),('shagun','mogha','shagun@gmail.com','shagun@123','Student',1),('Siddharth','Jain','siddharthjain@gmail.com','sid@12345','Student',1),('Alice','Student','student1@example.com','student123','Student',1),('student','one','studentone@gmail.com','student@1234','Student',1),('suniti','sharma','sunitisharma@gmail.com','suniti@123','Student',1),('tanishka','goyal','tanishka@gmail.com','tanisha@123','Student',1),('test','zero','test0@gmail.com','test@123','Admin',1),('test','one','test1@gmail.com','Test@123','Admin',1),('vansh','mehta','vanshmehta@gmail.com','vansha@!23','Student',1);
/*!40000 ALTER TABLE `login_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `result_status`
--

DROP TABLE IF EXISTS `result_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `result_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isDeclared` tinyint(1) DEFAULT '0',
  `declareDate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `result_status`
--

LOCK TABLES `result_status` WRITE;
/*!40000 ALTER TABLE `result_status` DISABLE KEYS */;
INSERT INTO `result_status` VALUES (1,0,'2025-11-16 20:42:53');
/*!40000 ALTER TABLE `result_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `result_table`
--

DROP TABLE IF EXISTS `result_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `result_table` (
  `applicationID` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `post` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resultStatus` enum('Accepted','Rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'Rejected',
  PRIMARY KEY (`applicationID`),
  CONSTRAINT `result_table_ibfk_1` FOREIGN KEY (`applicationID`) REFERENCES `application_table` (`applicationID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `result_table`
--

LOCK TABLES `result_table` WRITE;
/*!40000 ALTER TABLE `result_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `result_table` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-18 12:44:40
