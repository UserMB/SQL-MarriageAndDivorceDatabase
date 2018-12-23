---------------------------Queries and Views----------------------------------


--Show all marriages in Ireland with the date and place of marriage 
SELECT L.Country, V.PlaceOfMarriage, M.DateOfWedding
From Location L
INNER JOIN Venue V ON V.VenueAddress = L.LocationID 
INNER JOIN Marriage M ON V.VenueID = M.MarriageVenue
where Country = 'Ireland'; 


--Get the first names of all the people who are married
select p.FirstName
FROM PeopleAreMarried m
INNER JOIN Person p
ON p.PersonID IN (m.Person1, m.Person2);


----Marriage----
--This query is to show the marriage of the two people with first and second names within the database by the joining of  the person table primary key (PersonID) with the foreign keys (Person1, person2). 
SELECT PM.MarriageCertificateID, 
p1.FirstName as FirstNamePerson1, P1.Surname as SurnamePerson1,
P2.FirstName as FirstNamePerson2, P2.Surname as SurnamePerson2
from PeopleAreMarried PM
INNER JOIN Person P1 on P1.PersonID = PM.Person1
INNER JOIN Person P2 on P2.PersonID = PM.Person2;


----This query is to establish Same sex marriages---- 
--The following query below identifies all the marriages of  civil partnerships which is recognized by the where clause of the gender of both married couples, person1 gender is equal to person2 gender.
--(Could put this into a view and count the number of same sex marriages) 
SELECT m.MarriageCertificateID, 
p1.FirstName AS Person1FirstName, p1.Surname AS Person1Surname, p1.Gender AS Person1Gender, 
p2.FirstName AS Person2FirstName, p2.Surname AS Person2Surname, p2.Gender AS Person2Gender
from PeopleAreMarried m
INNER JOIN Person p1 on p1.PersonID = m.Person1
INNER JOIN Person p2 on p2.PersonID = m.Person2
where p1.Gender = 'M' AND p2.Gender = 'M' OR p1.Gender = 'F' AND p2.Gender = 'F';


----Same sex marriages view----
--Using a view inst
CREATE VIEW SameSexMarriage AS  
SELECT m.MarriageCertificateID, 
p1.FirstName AS Person1FirstName, p1.Surname AS Person1Surname, p1.Gender AS Person1Gender, 
p2.FirstName AS Person2FirstName, p2.Surname AS Person2Surname, p2.Gender AS Person2Gender
from PeopleAreMarried m
INNER JOIN Person p1 on p1.PersonID = m.Person1
INNER JOIN Person p2 on p2.PersonID = m.Person2
where p1.Gender = 'M' AND p2.Gender = 'M' OR p1.Gender = 'F' AND p2.Gender = 'F';

----Same sex marriages view query----
--Count the number of same sex marriages in the database
SELECT Count(MarriageCertificateID) AS NumberOfSameSexMarriages FROM SameSexMarriage;


----Forgein Marriages locations with first and second names----
--The database can detect marriages that don’t  happen in Ireland by joining of primary key and foreign keys, (VenueID PK = MarriageVenue FK, LocationID PK = VenueAddress FK, MarriageCertificateID PK  = MarriageCertificate FK, .PersonID PK = PM.Person1  FK, PersonID PK = PM.Person2  FK)  and using the where clause on the column Country in the location table to display all the location of marriages that do not equal to Ireland.  
SELECT p1.FirstName AS Person1FirstName, P1.Surname AS Person1Surname, 
p2.FirstName AS Person2FirstName, P2.Surname AS Person2Surname, L.Country AS LocationOfMarriage
From Marriage M
INNER JOIN Venue V ON V.VenueID = M.MarriageVenue 
INNER JOIN Location L ON L.LocationID = V.VenueAddress
INNER JOIN PeopleAreMarried PM ON PM.MarriageCertificateID = M.MarriageCertificate
INNER JOIN Person p1 on p1.PersonID = PM.Person1
INNER JOIN Person p2 on p2.PersonID = PM.Person2
Where Country != "Ireland";


----Civil Marriage----
--This query will identify all civil marriages from 2017, by the use of Inner join Marriage and Venue with the where clause on the place of marriage by date of marriage greater than 2017.
SELECT V.PlaceOfMarriage, M.DateOfMarriage
FROM Venue V
INNER JOIN Marriage M ON M.MarriageVenue = V.VenueID 
Where PlaceOfMarriage != "Church" AND DateOfMarriage > "2017";


----Divorce Details----
--Displays the divorce details of both parties with full names, the granted divorce date and shows if the divorce was due to a death.
SELECT D.District, D.DateOfApplicatonForDivorce, D.GrantedDivorceDate, CONCAT (P1.FirstName, ' ', P1.Surname) AS Person1FullName, P1.DateOfDeath, CONCAT (P2.FirstName, ' ', P2.Surname) AS Person2FullName, P2.DateOfDeath
FROM Divorce D
LEFT JOIN PeopleAreDivorce PD ON PD.PeopleAreDivorceID = D.PeopleAreDivorce
INNER JOIN Person P1 ON P1.PersonID = PD.Person1 
INNER JOIN Person P2 ON P2.PersonID = PD.Person2;


----Multiple marriages----
--Identifies the person(s) first Name, surname and Date Of Birth that have more than 1 marriage by the use of the 2 queries below begin union. 
SELECT PM.Person1 AS PersonID, P1.FirstName, P1.Surname, P1.DateOfBirth
FROM PeopleAreMarried PM
INNER JOIN Person P1 ON P1.PersonID = PM.Person1
GROUP BY PM.Person1   
HAVING COUNT(*) > 1
UNION ALL
SELECT PM.Person2 AS PersonID, P2.FirstName, P2.Surname, P2.DateOfBirth
FROM PeopleAreMarried PM
INNER JOIN Person P2 ON P2.PersonID = PM.Person2
GROUP BY PM.Person2 
HAVING COUNT(*) > 1;


----Multiple marriages view----
--A creation of view as alternative to a query would be less time consuming and begin more efficient to access these illegal marriages
CREATE VIEW MultipleMarriages AS  
SELECT PM.Person1 AS PersonID, P1.FirstName, P1.Surname, P1.DateOfBirth
FROM PeopleAreMarried PM
INNER JOIN Person P1 ON P1.PersonID = PM.Person1
GROUP BY PM.Person1   
HAVING COUNT(*) > 1
UNION ALL
SELECT PM.Person2 AS PersonID, P2.FirstName, P2.Surname, P2.DateOfBirth
FROM PeopleAreMarried PM
INNER JOIN Person P2 ON P2.PersonID = PM.Person2
GROUP BY PM.Person2 
HAVING COUNT(*) > 1;


----Illegal Family Marriages----
--Locate Illegal marriages by family members who have gotten married, this is indicated through the mother’s birth surname and father birth surname where both parties have the same mother and father birth surname. 
SELECT  CONCAT (P1.FirstName, ' ', P1.Surname) AS Person1FullName, P1.MotherBirthSurname AS Person1MotherBirthSurname , P1.FatherBirthSurname AS Person1FatherBirthSurname, 
CONCAT (P2.FirstName, ' ', P2.Surname) AS Person2FullName, P2.MotherBirthSurname AS Person2MotherBirthSurname , P2.FatherBirthSurname AS Person2FatherBirthSurname
From PeopleAreMarried PM
INNER JOIN Person P1 ON P1.PersonID = PM.Person1
INNER JOIN Person P2 ON P2.PersonID = PM.Person2
WHERE P1.MotherBirthSurname = P2.MotherBirthSurname AND P1.FatherBirthSurname = P2.FatherBirthSurname;


----Illegal Family Marriages view----
--A creation of view as alternative to a query would be less time consuming and begin more efficient to access these illegal marriages
CREATE VIEW IllegalFamilyMarriages AS
SELECT  CONCAT (P1.FirstName, ' ', P1.Surname) AS Person1FullName, P1.MotherBirthSurname AS Person1MotherBirthSurname , P1.FatherBirthSurname AS Person1FatherBirthSurname, 
CONCAT (P2.FirstName, ' ', P2.Surname) AS Person2FullName, P2.MotherBirthSurname AS Person2MotherBirthSurname , P2.FatherBirthSurname AS Person2FatherBirthSurname
From PeopleAreMarried PM
INNER JOIN Person P1 ON P1.PersonID = PM.Person1
INNER JOIN Person P2 ON P2.PersonID = PM.Person2
WHERE P1.MotherBirthSurname = P2.MotherBirthSurname AND P1.FatherBirthSurname = P2.FatherBirthSurname;

