-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 07, 2021 at 07:58 AM
-- Server version: 10.4.18-MariaDB
-- PHP Version: 8.0.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `baseroleplay`
--

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE `characters` (
  `pID` int(12) NOT NULL,
  `PlayerName` varchar(64) NOT NULL,
  `PlayerPassword` varchar(32) DEFAULT NULL,
  `PlayerPosX` float NOT NULL DEFAULT 0,
  `PlayerPosY` float NOT NULL DEFAULT 0,
  `PlayerPosZ` float NOT NULL DEFAULT 0,
  `PlayerSkin` int(8) DEFAULT 0,
  `PlayerAge` int(8) DEFAULT 0,
  `PlayerMoney` int(12) DEFAULT 0,
  `PlayerScore` int(12) DEFAULT 0,
  `PlayerGender` int(3) DEFAULT 0,
  `PlayerHealth` float NOT NULL DEFAULT 0,
  `PlayerLevel` int(12) DEFAULT 0,
  `PlayerCreated` int(3) NOT NULL DEFAULT 0,
  `PlayerAdmin` int(8) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `characters`
--
ALTER TABLE `characters`
  ADD PRIMARY KEY (`pID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `characters`
--
ALTER TABLE `characters`
  MODIFY `pID` int(12) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
