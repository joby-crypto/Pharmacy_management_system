-- Pharmacy Drug Management System - database schema
-- Run with:  mysql -u root -p < database/schema.sql

CREATE DATABASE IF NOT EXISTS drugdatabase;
USE drugdatabase;

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

CREATE TABLE customer (
  uid     varchar(20)  NOT NULL,
  pass    varchar(20)  DEFAULT NULL,
  fname   varchar(15)  DEFAULT NULL,
  lname   varchar(15)  DEFAULT NULL,
  email   varchar(30)  DEFAULT NULL,
  address varchar(128) DEFAULT NULL,
  phno    bigint       DEFAULT NULL,
  PRIMARY KEY (uid)
);

CREATE TABLE seller (
  sid     varchar(15)  NOT NULL,
  sname   varchar(20)  DEFAULT NULL,
  pass    varchar(20)  DEFAULT NULL,
  address varchar(128) DEFAULT NULL,
  phno    bigint       DEFAULT NULL,
  PRIMARY KEY (sid)
);

CREATE TABLE product (
  pid          varchar(15) NOT NULL,
  pname        varchar(20) DEFAULT NULL,
  manufacturer varchar(20) DEFAULT NULL,
  mfg          date        DEFAULT NULL,
  exp          date        DEFAULT NULL,
  price        int         DEFAULT NULL,
  PRIMARY KEY (pid),
  UNIQUE KEY pname (pname)
);

CREATE TABLE inventory (
  pid      varchar(15)  NOT NULL,
  pname    varchar(20)  DEFAULT NULL,
  quantity int unsigned DEFAULT NULL,
  sid      varchar(15)  NOT NULL,
  PRIMARY KEY (pid, sid),
  CONSTRAINT fk01 FOREIGN KEY (pid)   REFERENCES product (pid)   ON DELETE CASCADE,
  CONSTRAINT fk02 FOREIGN KEY (pname) REFERENCES product (pname) ON DELETE CASCADE,
  CONSTRAINT fk03 FOREIGN KEY (sid)   REFERENCES seller (sid)    ON DELETE CASCADE
);

CREATE TABLE orders (
  oid           int          NOT NULL AUTO_INCREMENT,
  pid           varchar(15)  DEFAULT NULL,
  sid           varchar(15)  DEFAULT NULL,
  uid           varchar(20)  DEFAULT NULL,   -- same length as customer.uid
  orderdatetime datetime     DEFAULT NULL,
  quantity      int unsigned DEFAULT NULL,
  price         int unsigned DEFAULT NULL,
  PRIMARY KEY (oid),
  CONSTRAINT fk04 FOREIGN KEY (pid) REFERENCES product (pid)  ON DELETE CASCADE,
  CONSTRAINT fk05 FOREIGN KEY (sid) REFERENCES seller (sid)   ON DELETE CASCADE,
  CONSTRAINT fk06 FOREIGN KEY (uid) REFERENCES customer (uid) ON DELETE CASCADE
);

ALTER TABLE orders AUTO_INCREMENT = 1000;

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

-- Stamp every new order with the current date and time.
DELIMITER //
CREATE TRIGGER updatetime BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    SET NEW.orderdatetime = NOW();
END//
DELIMITER ;

-- Reduce the seller's stock by the quantity that was just ordered.
DELIMITER //
CREATE TRIGGER inventorytrigger AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET quantity = quantity - NEW.quantity
    WHERE pid = NEW.pid AND sid = NEW.sid;
END//
DELIMITER ;

-- ---------------------------------------------------------------------------
-- Stored procedures
-- ---------------------------------------------------------------------------

DELIMITER //
CREATE PROCEDURE getsellerorders(IN param1 VARCHAR(20))
BEGIN
    SELECT * FROM orders WHERE sid = param1;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE getorders(IN param1 VARCHAR(20))
BEGIN
    SELECT * FROM orders WHERE uid = param1;
END//
DELIMITER ;
