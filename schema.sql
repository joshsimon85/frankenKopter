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
   email text,
   message text NOT NUll,
   pusblished boolean DEFAULT false
 );

 INSERT INTO testimonials (first_name, email, message)
             VALUES ('test', 'test@test.com', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus ut nulla sit amet risus ullamcorper dignissim. Phasellus id urna fringilla, semper sem nec, posuere lacus. Curabitur a mi eleifend, faucibus eros id, rhoncus est. Vestibulum tristique leo nulla, vel ultrices dolor fermentum at. Integer accumsan tellus non dictum sagittis. Aenean accumsan felis at dapibus aliquet. Aenean mollis nibh quis auctor blandit. Quisque neque ligula, ornare in laoreet non, condimentum sit amet risus. Suspendisse ut scelerisque ante. Donec feugiat laoreet massa tincidunt pharetra. Sed et luctus orci, ac vestibulum quam. Proin eu posuere eros, eu rhoncus tortor. Pellentesque tristique ipsum est, vitae volutpat dui posuere vel.');
