drop schema if exists Project cascade;
create schema Project;
set search_path to Project;

-- Rating for a company should between 1.0 and 5.0 and in 2 decimal spaces.
create domain Rating as numeric(10,2)
	default null
	check (value >= 1.0 and value <= 5.0);

-- Ownership for a company should be in {'Company - Private', 'College / University', 'Company - Public', 
--		'Contract', 'Franchise', 'Government', 'Hospital', 'Nonprofit Organization', 
--		'Other Organization', 'Private Practice / Firm', 'School / School District',
--		'Self-employed', 'Subsidiary or Business Segment'}	
create domain Ownership as text
	not null
	check (value in ('Company - Private', 'College / University', 'Company - Public', 
		'Contract', 'Franchise', 'Government', 'Hospital', 'Nonprofit Organization', 
		'Other Organization', 'Private Practice / Firm', 'School / School District',
		'Self-employed', 'Subsidiary or Business Segment'));

-- Company must be founded after year 1000, and between year 2050.	
create domain Founded as int
	default null
	check (value >= 1000 and value <= 2050);

-- Size of a company should be in {'1 to 50 employees','51 to 200 employees','201 to 500 employees',
-- '501 to 1000 employees','1001 to 5000 employees','5001 to 10000 employees', '10000+ employees'}	
create domain Size as varchar(50)
	not null
	check (value in ('1 to 50 employees','51 to 200 employees','201 to 500 employees','501 to 1000 employees','1001 to 5000 employees','5001 to 10000 employees',
	'10000+ employees'));

-- The unit for SalaryLowerBound is K (USD) and cannot be lower than 0.
create domain SalaryLowerBound as numeric(10,2)
	not null
	check (value >= 0);
	
-- The unit for SalaryUpperBound is K (USD) and must be greater than 0.	
create domain SalaryUpperBound as numeric(10,2)
	not null
	check (value > 0);	

-- The unit for RevenueLowerBound is million (USD) and cannot be lower than 0.
create domain RevenueLowerBound as numeric(10,2)
	not null
	check (value >= 0);
	
-- The unit for RevenueLowerBound is million (USD) and must be greater than 0.	
create domain RevenueUpperBound as numeric(10,2)
	not null
	check (value > 0);	

-- A location (city+state).
create table Location (
	-- Unique ID of the location.
	locationID integer primary key,
	-- City name of the location.
	city text not null,
	-- State name of the location.
	state text not null);

-- A sector.
create table Sector (
	-- Unique ID of the sector.
	sectorID integer primary key,
	-- Name of the sector.
	name text not null,
	-- The industry where the sector belongs to.
	industry text not null);

-- A headquarter of a company.
create table Headquarters(
	-- Unique ID of the headquarter.
	headID integer primary key,	
	-- Year when the headquarter is founded.	
	found Founded,
	-- Where the headquarter is located in.
	locationID integer,
	-- The lower bound of the revenue of the headquarter in million (USD).
	revenueLB RevenueLowerBound,
	-- The upper bound of the revenue of the headquarter in million (USD).
	revenueUB RevenueUpperBound,
	-- The size of the headquarter, i.e., 1 to 50 employees / 51 to 200 employees / 201 to 500 employees / 501 to 1000 employees
	-- 1001 to 5000 employees / 5001 to 10000 employees / 10000+ employees
	size Size,
	-- The upper bound of the revenue must be greater than or equal to the lower bound of the revenue.
	check (revenueUB >= revenueLB),
	foreign key (locationID) references Location);


-- A company (can be a branch company).
create table Company (
	-- Unique ID of the company.
	companyID integer primary key,
	-- Name of the company.
	name text not null,
	-- The average rating of the company.
	rating Rating,
	-- Where the company is located.
	locationID integer not null,
	-- Ownership of the company, for example, 'Company - Private' / 'Company - Public' / 'Franchise', etc.
	ownership Ownership,
	-- Headquarter of the company.
	headID integer,
	foreign key (locationID) references Location,
	foreign key (headID) references Headquarters);


-- A job in a company.
create table Job (
	-- Unique ID of the job.
	jobID integer primary key,
	-- The company of the job.
	companyID integer not null,
	-- Title of the job.
	title text not null,
	-- The sector which the job belongs to.
	sectorID integer,
	-- The lower bound of the salary of the job in K (USD).
	salaryLB SalaryLowerBound,
	-- The upper bound of the salary of the job in K (USD).s
	salaryUB SalaryUpperBound,
	-- The description of the job.
	description text,
	-- The upper bound of the salary must be greater than or equal to the lower bound of the salary.
	check (salaryUB >= salaryLB),
	foreign key (sectorID) references Sector);

-- 	A competition relationship between two companies.
create table Competition(
	-- Company aID and company bID have a competition relationship.
	-- companyID of the first company.
	aID integer not null,
	-- companyID of the second company.
	bID integer not null,	
	primary key (aID, bID),	
	foreign key (aID) references Company,
	foreign key (bID) references Company);