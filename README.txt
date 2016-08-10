0. Showing method chaining and some meta programming techniques.
1. Using mysql library
2. SQL dump file: my_db.sql
3. Ruby file: project_meta.rb

----- Sequences in starting server, creating DB, creating tables, and inserting table values

- mysqld
- msql -u root
- CREATE DATABASE my_db;
- USE my_db;
- DROP TABLE IF EXISTS `water_samples`;

- CREATE TABLE `water_samples` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `site` varchar(255) DEFAULT NULL,
  `chloroform` float DEFAULT NULL,
  `bromoform` float DEFAULT NULL,
  `bromodichloromethane` float DEFAULT NULL,
  `dibromichloromethane` float DEFAULT NULL,
  PRIMARY KEY (`id`)
  ) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

- LOCK TABLES `water_samples` WRITE;
  INSERT INTO `water_samples` VALUES (1,'Sunnyvale pump station',0.00104,0,0.00149,0.00275),(2,'Cupertino pump station',0.00291,0.00487,0.00547,0.0109),(3,'Saratoga pump station',0.00065,0.00856,0.0013,0.00428),(4,'Mountain View pump station',0.00971,0.00317,0.00931,0.0116);
  UNLOCK TABLES;

- DROP TABLE IF EXISTS `factor_weights`;

  CREATE TABLE `factor_weights` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chloroform_weight` float DEFAULT NULL,
  `bromoform_weight` float DEFAULT NULL,
  `bromodichloromethane_weight` float DEFAULT NULL,
  `dibromichloromethane_weight` float DEFAULT NULL,
  PRIMARY KEY (`id`)
  ) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

  LOCK TABLES `factor_weights` WRITE;
  INSERT INTO `factor_weights` VALUES (1,0.8,1.2,1.5,0.7),(2,1,1,1,1),(3,0.9,1.1,1.3,0.6),(4,0,1,1,1.7);
  UNLOCK TABLES;

----- mysql dumping command -----

mysqldump -u root my_db > my_db.sql
