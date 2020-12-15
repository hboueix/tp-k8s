CREATE DATABASE IF NOT EXISTS wordpress;

CREATE USER 'wordpress'@'%' IDENTIFIED BY 'M0td3p4ss3';
ALTER USER 'wordpress'@'%' IDENTIFIED WITH mysql_native_password BY 'M0td3p4ss3';

GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';

FLUSH PRIVILEGES;

-- USE wordpress;

-- CREATE TABLE IF NOT EXISTS wordpress;




-- USE `mysql`;

-- DROP TABLE IF EXISTS
--     `kubedb_table`;

-- CREATE TABLE `kubedb_table`(
--     `id` BIGINT(20) NOT NULL,
--     `name` VARCHAR(255) DEFAULT NULL
-- );

-- --
-- -- Dumping data for table `kubedb_table`
-- --

-- INSERT INTO `kubedb_table`(`id`, `name`)
-- VALUES(1, 'name1'),(2, 'name2'),(3, 'name3');

-- --
-- -- Indexes for table `kubedb_table`
-- --

-- ALTER TABLE
--     `kubedb_table` ADD PRIMARY KEY(`id`);

-- --
-- -- AUTO_INCREMENT for table `kubedb_table`
-- --

-- ALTER TABLE
--     `kubedb_table` MODIFY `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
--     AUTO_INCREMENT = 4;