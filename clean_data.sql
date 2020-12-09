-- Clean Headquarters
CREATE TEMPORARY TABLE Headtemp (
	headID integer,		
	found integer,
	locationID integer,
	revenueLB numeric(10,2),	
	revenueUB numeric(10,2),
	size varchar(50));

--insert the data
\COPY Headtemp from 'Headquarters.csv' delimiter ','  csv encoding 'ISO-8859-1'

DELETE FROM Headtemp
WHERE Headtemp.revenueLB < 0 or Headtemp.revenueUB < 0;

DELETE FROM Headtemp
WHERE Headtemp.found < 0;

DELETE FROM Headtemp
WHERE Headtemp.Size not in ('1 to 50 employees','51 to 200 employees','201 to 500 employees','501 to 1000 employees','1001 to 5000 employees','5001 to 10000 employees',
	'10000+ employees');

\COPY Headtemp TO 'Head_clean.csv' csv encoding 'ISO-8859-1'

--Company table
CREATE TEMPORARY TABLE Companytemp (companyID integer,
	name text not null,
	rating numeric(10,1),
	locationID integer,
	ownership text,
	headID integer);
	
\COPY Companytemp from 'Company.csv' delimiter ',' csv encoding 'ISO-8859-1'

DELETE FROM Companytemp
WHERE Companytemp.rating < 0;

DELETE FROM Companytemp
WHERE Companytemp.ownership not in ('Company - Private', 'College / University', 'Company - Public', 
		'Contract', 'Franchise', 'Government', 'Hospital', 'Nonprofit Organization', 
		'Other Organization', 'Private Practice / Firm', 'School / School District',
		'Self-employed', 'Subsidiary or Business Segment');

DELETE FROM Companytemp
WHERE Companytemp.locationID < 0;

DELETE FROM Companytemp
WHERE Companytemp.headID not in (
	SELECT headID
	FROM Headtemp
);

\COPY Companytemp TO 'Company_clean.csv' csv encoding 'ISO-8859-1'

--Competition table
CREATE TEMPORARY TABLE Comptemp (	
	aID integer,
	bID integer);
	
\COPY Comptemp from 'Competition.csv' delimiter ',' csv encoding 'ISO-8859-1'

DELETE FROM Comptemp
WHERE Comptemp.bID not in (
	SELECT companyID
	FROM Companytemp
);

DELETE FROM Comptemp
WHERE Comptemp.aID not in (
	SELECT companyID
	FROM Companytemp
);

\COPY Comptemp TO 'Competition_clean.csv' csv encoding 'ISO-8859-1'

--Job table
CREATE TEMPORARY TABLE Jobtemp (	
	jobID integer,
	companyID integer,
	title text,
	sectorID integer,
	salaryLB integer,
	salaryUB integer,
	description text);
	
\COPY Jobtemp from 'Job.csv' delimiter ',' csv encoding 'ISO-8859-1'

DELETE FROM Jobtemp
WHERE Jobtemp.companyID not in (
	SELECT companyID
	FROM Companytemp
);

\COPY Jobtemp TO 'Job_clean.csv' csv encoding 'ISO-8859-1'

-- Drop table
DROP TABLE Headtemp;
DROP TABLE Companytemp;
DROP TABLE Comptemp;
DROP TABLE Jobtemp;