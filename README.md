# fetch-rewards-data-analyst-assessment
Demonstrating how I reason about the Fetch Take Home assessment data and how I communicate my understanding of specific datasets to others.

## Requirements
- Review unstructured JSON data and diagram a new structured relational data model
- Generate a query that answers a predetermined business question
- Generate a query to capture data quality issues against the new structured relational data model
- Write a short email or Slack message to the business stakeholder

## 1. Relational Data Model
<img src="./relational-data-model.png" alt="Diagram of relational model" />

## 2. SQL Query (T-SQL)
I chose questions 3 and 4. Here is my query:
- Question 3: When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
- Question 4: When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

```sql
SELECT
  r.rewardsReceiptStatus AS receiptStatus,
  ROUND(AVG(r.totalSpent),2) AS Average_totalSpent,
  SUM(r.purchasedItemCount) AS Total_purchasedItemCount
FROM
  FetchRewards.dbo.receipts r
WHERE
  r.rewardsReceiptStatus in ('FINISHED', 'REJECTED')
GROUP BY
  r.rewardsReceiptStatus;
```
--TEXT GOES HERE FOR ANSWER SUMMARY--

![sql-3-4-output](https://github.com/brian-millerj/fetch-rewards-data-analyst-assessment/assets/68014965/851ff24a-23ea-4aeb-893d-36cbb2a769ac)


## 3. Data Quality
To evaluate data quality there are several factors to take into considerations that are given as examples in the below queries, such as:
- Duplicate data
- Ambiguous data
- Inconsistent data
- Incomplete data

### Identifying Duplicate Data
Using the "users" table for this example, we want to ensure that the table does not include any duplicate records.

The column "userId": in the "users" table should be the unique identifier within the table (ie. one row per userId). Using a few simple queries, we can quickly identify duplicates within the table.

This first approach is simply counting the total number of records in the table compared to the distinct number of userId's. Running the query below, we see that there are 495 total records in the table compared to the 212 unique userId's.
```sql
SELECT
	COUNT(*) AS totalUserRecords,
	COUNT(DISTINCT userId) AS uniqueUsers
FROM 
	FetchRewards.dbo.users u;
```
![duplicate-user-count](https://github.com/brian-millerj/fetch-rewards-data-analyst-assessment/assets/68014965/0ae2ecfe-2149-4f9a-8e97-80d3afb0692b)

Understanding that there a duplicate UserId's, is this coming from a specific user or multiple users? Running the query below, we see that there are several users that have 2+ records, two of which have 20 records ('54943462e4b07e684157a532', 5fc961c3b8cfca11a077dd33').
```sql
select
	userId,
	count(userId) AS countOfUserId 
FROM 
	FetchRewards.dbo.users u
GROUP BY
	USERID
order by 
	COUNT(userId) DESC;
```
![usersid-counts](https://github.com/brian-millerj/fetch-rewards-data-analyst-assessment/assets/68014965/c1dfc2c9-77fc-4de0-9667-c73e1d6f476e)

Let's take a look at the raw data of one of the records that have 20 records ('54943462e4b07e684157a532') to understand further if each row is the same. Upon executing the below query, each of the 20 rows returns the same information.
```sql
select
	userId,
	active,
	[role],
	signUpSource,
	[state],
	CAST(DATEADD(ss, createdDate/1000, '1970-01-01') AS DATE) AS createDate,
	CAST(DATEADD(ss, lastLoginDate/1000, '1970-01-01') AS DATE) AS lastLoginDate
from FetchRewards.dbo.users u
WHERE
  userId = '54943462e4b07e684157a532'
```
![userid-example](https://github.com/brian-millerj/fetch-rewards-data-analyst-assessment/assets/68014965/c85bc2bf-fe1c-443c-b8af-855be4b8c390)

### Identifying Ambiguous and Inconsistent data

### Identifying Incomplete Data
The below query identifies NULL values dynamically within a table to help understand the completeness of the data. If we consider the 'brands' table, the query below quickly identifies that there are:
- 650 rows with a NULL CategoryCode (56% of total rows)
- 155 rows with a NULL Category (13% of rows)
- 269 rows with a NULL brandCode (23% of columns)
- 612 rows with a NULL topBrand (52% of columns)

```sql
DECLARE @null_sql VARCHAR(MAX)

SELECT
    @null_sql = COALESCE(@null_sql + ', ', '') +  'SUM(CASE WHEN ' + COLUMN_NAME + ' IS NULL THEN 1 ELSE 0 END) AS ' + COLUMN_NAME
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
  TABLE_NAME = 'brands' --change 'brands' to another table (such as 'users') to understand data completeness of a different table in the database

SET @null_sql = 'SELECT ' + @null_sql

SET @null_sql = @null_sql + ' FROM brands'  --change 'brands' to another table (such as 'users') to understand data completeness of a different table in the database

PRINT @null_sql

EXEC(@null_sql)
```
![NULL-data](https://github.com/brian-millerj/fetch-rewards-data-analyst-assessment/assets/68014965/9e291a59-abbe-4ee1-8a24-0b512194ab6b)

## 4. Stakeholder Communication
