CREATE DATABASE IF NOT EXISTS franken_kopter

CREATE TABLE emails (
   id SERIAL PRIMARY KEY,
   first_name varchar(50) NOT NULL,
   last_name varchar(50) NOT NULL,
   phone_number varchar(50),
   email text NOT NULL,
   message text NOT NULL,
   sent timestamp NOT NULL DEFAULT NOW()
 );

 CREATE TABLE admins (
   id SERIAL PRIMARY KEY,
   first_name varchar(50) NOT NULL,
   last_name varchar(50) NOT NULL,
   email text NOT NULL,
   user_name varchar(50) NOT NULL,
   password  varchar NOT NULL
 );

 CREATE TABLE testimonials (
   id SERIAL PRIMARY KEY,
   first_name varchar(50) NOT NULL,
   last_name varchar(50) NOT NULL,
   email text,
   body text NOT NUll,
   published boolean DEFAULT FALSE,
   sent timestamp NOT NULL DEFAULT NOW()
 );
