
exec sp_helptext uf_SearchGuestByNameOrLastName
--------------------------------------------------------------------------------------
--- FUNCTION DEFINITION
--- uf_SearchGuestByNameOrLastName (@NameOrSurname varchar(60))
--------------------------------------------------------------------------------------
-- wyszukiwanie informacji o goœciu na podstawie fragmentu imienia lub nazwiksa
--
-- parametry wejœciowe:
-- @NameOrSurname - wyszukiwane imiê lub nazwisko goœcia
--
--parametry wyjœciowe/zwracane wartoœci:
--zwraca tabelê z informacjami o goœciu, który zosta³ wyszukany
--
/*
use HotelDatabase
go
Select uf_SearchGuestByNameOrLastName ('Doe')
--
--Wynik dzia³ania
--Zwraca 2 rekordy tabeli, poniewa¿ w bazie znajduj¹ siê 2 osoby o nazwisku 'Doe'
--------------------------------------------------------------------------------------
*/   

use HotelDatabase
go
CREATE OR ALTER FUNCTION uf_SearchGuestByNameOrLastName(@NameOrSurname varchar(60))
RETURNS TABLE
AS
RETURN(
SELECT g.IdGuest,g.IDNumber, g.LastName, g.Name, g.PassportNumber, pd.* 
FROM [hotel].[tbl_guests] as g inner join [hotel].[tbl_people_data] as pd
on g.IdPersonData=pd.IdPersonData
WHERE LOWER([Name])+' '+LOWER([LastName]) LIKE LOWER('%'+@NameOrSurname+'%'))
GO
