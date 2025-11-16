CREATE TABLE IF NOT EXISTS projects (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255),
    description VARCHAR(255),
    PRIMARY KEY (id)
);

INSERT INTO projects (name, description) VALUES
('Project 1', 'Description for Project 1'),
('Project 2', 'Description for Project 2');
