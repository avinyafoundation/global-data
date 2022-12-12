-- MySQL dump 10.13  Distrib 8.0.30, for Win64 (x86_64)
--
-- Host: avinya-db-production.mysql.database.azure.com    Database: avinya_db
-- ------------------------------------------------------
-- Server version	8.0.28

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
-- Table structure for table `avinya_type`
--

DROP TABLE IF EXISTS `avinya_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `avinya_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `active` tinyint(1) NOT NULL,
  `global_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Unknown',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `foundation_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `focus` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `avinya_type`
--

LOCK TABLES `avinya_type` WRITE;
/*!40000 ALTER TABLE `avinya_type` DISABLE KEYS */;
INSERT INTO `avinya_type` VALUES (1,1,'Organization','Foundatio, The Super Parent Organization',NULL,NULL,1000),(2,1,'Organization','Avinya Acadamy School',NULL,NULL,500),(3,1,'Team','Advisors Team','Advisors',NULL,400),(4,1,'Team','Executive Team','Executive',NULL,300),(5,1,'Team','Technology Team','Technology',NULL,250),(6,1,'Team','Team of educators','Educator',NULL,250),(7,1,'Team','Team who handles operations','Operations',NULL,250),(8,1,'Team','HR Team','HR',NULL,250),(9,1,'Team','Foundation Program','Educator','Foundation',200),(10,1,'Team','Vocational IT','Educator','Vocational-IT',200),(11,1,'Team','Vocational Healthcare','Educator','Vocational-Healthcare',200),(12,1,'Team','Vocational Hospitality','Educator','Vocational-Hospitality',200),(13,1,'Team','Shool Operations','Operations','Operations',250),(14,1,'Employee','Executive Director','Executive',NULL,1000),(15,1,'Employee','CTO','Technology',NULL,900),(16,1,'Employee','Head - Foundation Program','Educator','Foundation',800),(17,1,'Employee','Head - IT','Educator','Vocational-IT',800),(18,1,'Employee','Head - Healthcare','Educator','Vocational-Healthcare',800),(19,1,'Employee','Head - Hospitality','Educator','Vocational-Hospitality',800),(20,1,'Employee','Head - Operations','Operations','Operations',800),(21,1,'Employee','Head - HR','HR','HR',800),(22,1,'Employee','Head - School Operations','Operations','Operations',700),(23,1,'Employee','Strategy and Technology Consultant','Technology',NULL,700),(24,1,'Employee','Software Engineer','Technology','Technology',200),(25,1,'Employee','Educator - Foundation Program','Educator','Foundation',500),(26,1,'applicant','student-applicant','student','empower',0);
/*!40000 ALTER TABLE `avinya_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-12-08 14:31:44
