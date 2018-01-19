*Some tips and examples of SQL in SPSS using SMRA views, which can be applied to other databases
Updated July 2017
Jaime Villacampa

*SQL always needs two parameters: SELECT (what fields you want) and FROM (what table you want).
*WHERE is another command highly used, it is used to add any condition (e.g. time period, age, diagnosis).
*Additionally, there are other commands like JOIN (for more than one table), GROUP BY (to aggregate) and ORDER BY (to sort cases).

 * This is an useful web to learn SQL: http://www.w3schools.com/sql/default.asp

*Common problems/errors while writing SQL code in SPSS:
    Problems with simple and double quotation marks. Use the double one to end lines and the simple one to define string terms.
 *     Symbol + at the end of lines. If there is more lines there has to be a + symbol.
 *     Commas before FROM, or lack of commas between fields.
 *     There needs to be a blank space at the end of a line or at the beggining of the next.

**********************************************************************
How to hide your password from the code
**********************************************************************    
Create an SPSS syntax file into your Unix home folder (e.g. "/home/USERNAME/SMRA_pass.sps") with the following code:
PRESERVE.
SET PRINTBACK NONE.
**turns off syntax printing temporarily.

DEFINE !connect()
Your password here (e.g. 'DSN=SMRA;UID=USERNAME;PWD=PASSWORD;SRVR=NSSSERVERNAME')
!ENDDEFINE.

** turn printing back on.
RESTORE.

 * End of code in password file
*************
**After that, you will have to add at the beggining of your SPSS syntax:

INSERT FILE = "Location of your file (e.g./home/USERNAME/SMRA_pass.sps").

*And change the connect statement in the get data command to:.
  /CONNECT= !connect

**********************************************************************
How to look for data on an specific period of time
**********************************************************************
*The code to add a date condition in SQL-SPSS is a bit complicated.
*In the following example data is retrieved between 1-1-16 and the 2-1-16.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT admission_date "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and '2016-01-02' " 
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to select data for a field
**********************************************************************
*In the following example data is retrieved for the Monkland hospital patients over 65.
*Logic operators are used to indicate the conditions of the query: and, or,=, >,<, >=,=<, <>.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT location, age_in_years "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and '2016-01-02' " +
        "and age_in_years>65 "+
        "and location = 'L106H' "  
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to select several string values at once
**********************************************************************
*When you want to extract more than one value in a string field, the function IN is very useful. It is equivalent to a series of OR each one with a different string value.
*In the following example data is retrieved for Monkland and Southern General patients.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT location "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and '2016-01-02' " +
    "and location in ('L106H', 'G405H') " 
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to exclude missing values
**********************************************************************
*This is done with the expression is not null. If you wanted to pull out the records with missing values you should use "is null".
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT postcode "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and '2016-01-02' " +
    "and postcode is not null " 
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to look for an specific string expression (e.g, diagnosis, word)
**********************************************************************
*This is done through the regexp_like expression. This looks for the text that you want in the field, in a particular position or in any.
*Regular expressions are very powerful and for example can be adjusted to look for strings in specific parts of the field.
 * In this example we retrieve patients that had a diganosis of C51 to C58. We show two ways of doing it.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT main_condition "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and '2016-01-10' " +
     "and REGEXP_LIKE(main_condition,'C51|C52|C53|C54|C55|C56|C57|C58') "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT main_condition "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and '2016-01-10' " +
     "and REGEXP_LIKE(main_condition,'C5[1-8]')"
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*In some simpler cases, the function "like" can be used as well, faster but more limited.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT main_condition "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and '2016-01-10' " +
         "and main_condition like 'C5%'  "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*We use the function lower to make the search case insensitive. We could use the function upper as well.
*In this example we look for a series of presenting complaints at A&E, where they could be in upper or in lower case.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT surname "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-06-01' and '2016-07-01' " +
    "and regexp_like(Lower(surname),'taylor|smith|jones|williams') "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to sort cases
**********************************************************************
*This is done with the ORDER BY command that is placed at the end of the SQL code. More than one variable can be used to sort.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT admission_date, length_of_stay, location "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and  '2016-02-01' " +
    "order by length_of_stay, location "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*To obtain the same sort order than in the old linked catalog file, you can sort it this way:
* You don't need to include your order by variables in your select command if you don't want.
* For more information about this, consult SAF bulletin no 16.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT admission_date, length_of_stay, location "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and  '2016-02-01' " +
    "order by LINK_NO, ADMISSION_DATE, DISCHARGE_DATE, ADMISSION, DISCHARGE, URI "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*********************************************************************
How to combine two fields into one.
**********************************************************************
*This example joins together the forename and fullname to create a full name field.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT First_forename || ' ' || surname as full_name "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2016-01-01' and  '2016-02-01' " +
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to aggregate data
**********************************************************************
*The aggregate SPSS command has an equivalent in SQL. There are several ways of doing it, with different functions for it: count, average, sum, max, min. 
*Median is not calculated in a straightforward way (sort by the field you are interested and calculate the mid value) - probably better through SPSS.
*The command GROUP By needs to be used together with these functions. More than one field can be included in the group by command.
*In this example we calculate the count of records, and the mean, sum, max and min lenght of stay by hospital.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT location, count(link_no) count, avg(length_of_stay) mean, sum(length_of_stay) sum, max(length_of_stay) max, min(length_of_stay) min  "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2013-07-01' and '2013-07-06' " +
    "group by location "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*SQL can also provide totals for each group category. This is done using rollup.
*In this case it will provide the total for all the hospitals.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT location, count(link_no) count, avg(length_of_stay) mean, sum(length_of_stay) sum, max(length_of_stay) max, min(length_of_stay) min  "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2013-07-01' and '2013-07-06' " +
    "group by rollup(location) "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to select distinct-unique values
**********************************************************************
*Many times you might be interested in just getting to know the range of values of an specific field.
*This is quickly done with the select distinct expression. In this case we look to the list of different hospitals/locations in Scotland.
*If you add more than one variable it will provide you a list of all the combinations found.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT distinct location  "+
    "FROM ANALYSIS.SMR01_PI "+
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*Distinct can be used for other purposes, for example to avoid double counting of episodes in the inpatient tables.
*In this example, we count the number of different episodes, admissions and patients in each hospital, using the distinct and the total method.
*The distinct method counts only once each different link_no for each hospital, the total one counts how many rows have that value (excluding missing).
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT location, count (link_no) total_count, count(distinct link_no) patient_count, count(distinct link_no || '-' || cis_marker) admission_count  "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2013-07-01' and '2013-07-03' " +
    "group by location " 
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to calculate calendar year, financial year, month, month-year, weekday
**********************************************************************
*This example retrieves the admissions calendar year, financial year, month, month-year, quarter, week number and weekday .
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT extract(year from admission_date) as Calendar_year, "+
       "CASE WHEN extract(month from admission_date) > 3 THEN extract(year from admission_date) ELSE extract(year from admission_date) -1 END as Financial_year, "
       "extract(month from admission_date) Month, "+
       " to_date(to_char(admission_date, 'MON-YY'), 'MON-YY') Month_year, "+
       "TO_CHAR(admission_date, 'Q') quarter, "
       " to_char(admission_date, 'Day') Weekday, "+
       " to_char(admission_date, 'YY-WW') Week_number, "+
       "count (link_no) Episodes "+
    "FROM ANALYSIS.SMR01_PI "+
    "where admission_date between '2013-07-01' and '2014-08-01' " +
    "group by extract(year from admission_date), TO_CHAR(admission_date, 'Q'), extract(month from admission_date), " +
      "CASE WHEN extract(month from admission_date) > 3 THEN extract(year from admission_date) ELSE extract(year from admission_date) -1 END, "+
       "to_date(to_char(admission_date, 'MON-YY'), 'MON-YY'), to_char(admission_date, 'Day'), to_char(admission_date, 'YY-WW') " +
    "order by Week_number "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*********************************************
Extracting a part of a string
*********************************************
In this example, we are extracting the first 3 characters of the main cause of death.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT substr(PRIMARY_CAUSE_OF_DEATH,1,3) pcause, count(link_no) number_deaths " +
    "FROM ANALYSIS.GRO_DEATHS_C "+
    "WHERE date_of_registration between '2014-01-01' and '2015-12-31' "+
     "group by substr(PRIMARY_CAUSE_OF_DEATH,1,3) "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*********************************************
Retrieving the lenght of a string
*********************************************.
*In this example we obtained the lenght of each postcode string.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT postcode, LENGTH(postcode) len_pc "+
    "FROM ANALYSIS.GRO_DEATHS_C "+
    "WHERE date_of_registration between '2014-01-01' and '2015-12-31' "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to extract data from one table if it exists in another table/query
**********************************************************************
*The table we are extracting data from receives an alias (z in this case), and the linking variable (UAI in this case) needs to have that alias in front.
*In this example we extract all admissions for an individual from the inpatient table if that individual have had a previous 
admission due to COPD .
*Another case when this function could be useful is to look into inpatient information of individuals that have gone through an appointment
in an specific clinic.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select link_no, cis_marker, AGE_IN_YEARS, admission_date, main_condition "+
      "FROM ANALYSIS.SMR01_PI Z "+
      "where admission_date between '2015-04-01' and '2016-04-01' " +
         "and exists (select * from ANALYSIS.SMR01_PI  where link_no=z.link_no and cis_marker=z.cis_marker "+
      		      "and admission_date between '2015-04-01' and '2016-04-01' "+
      	      	"and regexp_like(main_condition, 'J4[0-4]') ) "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to extract information from two tables at the same time.
**********************************************************************
*This is done through the INNER JOIN, FULL OUTER JOIN and LEFT JOIN commands.
*The LEFT JOIN keyword returns all rows from the left table (the one included in from), with the matching rows in the right table (the one in the join command). 
*The result is NULL in the right side when there is no match.
 * The INNER JOIN keyword selects all rows from both tables as long as there is a match between the columns in both tables.
 * The FULL OUTER JOIN keyword returns all rows from the left table (table1) and from the right table (table2).    

*In this example we combine the information from the date of death with inpatient information through the linkno.
*It shows how many patients died in each hospital per year and how many didn't.
*Each table receive an alias (h and z in this case), and each variable needs to have that alias in front.
GET DATA
    /TYPE=ODBC
    /CONNECT= !connect
    /SQL="SELECT z.year_of_registration, h.location, count(distinct h.link_no) patients " +
    "FROM ANALYSIS.SMR01_PI H "+
    "LEFT JOIN ANALYSIS.GRO_DEATHS_C Z ON h.link_no = z.link_no " +
    "WHERE h.admission_date between '2015-11-01' and  '2016-02-01' "+
          "and h.INPATIENT_DAYCASE_IDENTIFIER='I' " +
    "group by h.location, z.year_of_registration "
    /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*In this example, we retrieve information about road traffic casualties, both admissions and deaths.
*Union all brings all the information from two or more tables, but they have to have the same column names.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="select link_no, year_of_registration year, age, SEX sex_grp, POSTCODE pc7, null as cis_marker "+
                  "from ANALYSIS.GRO_DEATHS_C "+ 
                     "where date_of_registration between  '2015-01-01' and '2015-12-31' " +
                      "and country_of_residence='XS' "+
                       "and regexp_like(PRIMARY_CAUSE_OF_DEATH, 'V[0-8]') "+
                      "and age is not NULL "+
                      "and sex <> 9 "+
           "UNION ALL "+
             "select link_no, extract(year from admission_date) year, AGE_IN_YEARS age, SEX sex_grp, DR_POSTCODE pc7, cis_marker "+
              "from ANALYSIS.SMR01_PI z "+
              "where admission_date between '2015-01-01' and '2015-12-31'  "+
               "and exists(select * from ANALYSIS.SMR01_PI where link_no=z.link_no and cis_marker=z.cis_marker "+
                        "and admission_type=32 "+
                        "and admission_date between '2002-01-01' and '2016-01-01') "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
How to create a variable based on a condition
**********************************************************************
In this case we selected patients with an specific diagnosis and we create a category to indicate if they have more than 65 years.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT count(distinct link_no || '-' || cis_marker) admission_count,   "+
       "case when age_in_years>65  then 'Y' else 'N' end More_65 "+
    "FROM ANALYSIS.SMR01_PI "+
    "WHERE admission_date between '2015-04-01' AND '2016-04-01' "+
       "and main_condition like 'C1%' " +
    "group by case when age_in_years>65  then 'Y' else 'N' end "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
To simplify queries when they get overly complicated with conditions
**********************************************************************.
*To reduce risk of problems with brackets and and/or's.
*This example selects a series of inpatient cases for a certain period and a certain location and a different period for a different hospital.
 *  Using and/s and or/s and parenthesis syntax would be long and complex.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT admission_date, discharge_date, location, link_no "+
    "FROM ANALYSIS.SMR01_PI  "+
    "WHERE INPATIENT_DAYCASE_IDENTIFIER='I' "+
        " and case when (admission_date between '2015-04-01' and '2016-03-31' "+
               "or discharge_date between '2015-04-01' and '2016-04-01') "
               "and location='G405H' THEN 1 " +
        " when location='L106H' "+
               "and admission_date between '2015-09-19' and '2015-10-23' THEN 1 ELSE 0 end=1 " +
    "order by link_no, admission_date "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
To create categories of cases
**********************************************************************.
*Using the case function we can aggregate data based on categories.
*In this case we count admissions, split in different categories based on their type.
GET DATA
  /TYPE=ODBC
  /CONNECT=!connect
  /SQL="SELECT HBTREAT_CURRENTDATE, "+
       "count(*) ipdc,   "+
       "count (case when INPATIENT_DAYCASE_IDENTIFIER ='D' then DISCHARGE_DATE end) Daycases, " +
       "count (case when INPATIENT_DAYCASE_IDENTIFIER ='I' then DISCHARGE_DATE end) totalip, " +
       "count (case when ADMISSION_TYPE in ('10', '11', '12', '19') and INPATIENT_DAYCASE_IDENTIFIER='I' then DISCHARGE_DATE end) Elective_ip, " +
       "count (case when ADMISSION_TYPE in ('20', '21', '22', '30', '31', '32', '33', '34', '35', '36', '38', '39') then DISCHARGE_DATE end) Emergency, " +
       "count (case when ADMISSION_TYPE = 18 and INPATIENT_DAYCASE_IDENTIFIER='I' then DISCHARGE_DATE end) Transfers " +
    "FROM ANALYSIS.SMR01_PI "+
   "WHERE DISCHARGE_DATE between '2015-12-01' AND '2016-01-31' "+
      "and specialty in ('C1','C11','C12','C13','C4','C41','C42','C5','C6','C7','C8','C9','CA','CB','D3','D4','D5','D6','D8','F2', "+
         " 'A1','A11','A2','A6','A7','A8','A81','A82','A9','AA','AB','AC','AD','AF','AG','AH','AM','AP','AQ','AR','C2','C3','D1','E12','H1','H2','J4','R1','R11') "
   "GROUP BY HBTREAT_CURRENTDATE  "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

**********************************************************************
To select only if more than x results
**********************************************************************.
*Using the case function we can aggregate data based on categories.
*Two ways of doing, but they extract the same data. Both of them use the function having, which includes the count condition.
*In the example, we are pulling the number of patients with more than one episode to an speciffic hospital during a period of time.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT count(*) count_episode, link_no "+
    "FROM ANALYSIS.SMR01_PI "+
    "where discharge_date between '2016-06-01' and '2016-09-01' " +
        "and location='L106H' "+
          "and link_no in " +
                "(select link_no FROM ANALYSIS.SMR01_PI "+
                "where discharge_date between '2016-06-01' and '2016-09-01'  "+
                    "and location='L106H' "+
                "group by link_no having count(link_no)>1 ) " +
    "group by link_no"
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

*This approach can retrieve the same results as the previous one. 
*However is coded to retrieve the information on the episodes of patients with more than episode, instead of providing a count.
GET DATA
  /TYPE=ODBC
  /CONNECT= !connect
  /SQL="SELECT  z.link_no, z.admission_date, z.discharge_date "+
    "FROM ANALYSIS.SMR01_PI z "+
    "join(select z2.link_no FROM ANALYSIS.SMR01_PI z2 "+
             "where z2.discharge_date between '2016-06-01' and  '2016-09-01' "+
                    "and z2.location='L106H' "+
             "group by z2.link_no having count(*)>1) z2 on z2.link_no=z.link_no "
    "where z.discharge_date between '2016-06-01' and  '2016-09-01' "+
        "and z.location='L106H' "
  /ASSUMEDSTRWIDTH=255.
CACHE.
EXECUTE.

******************************************************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************************************************
******************************************************************************************************************************************************************************************************************