CREATE TABLE vicroads_vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(60),
    plate VARCHAR(12),
    expiry DATETIME
);

CREATE TABLE vicroads_questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    license VARCHAR(50),
    question TEXT,
    answers TEXT,
    correct INT
);
