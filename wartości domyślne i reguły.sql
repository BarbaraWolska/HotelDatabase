--wartoœci domyœlne

CREATE DEFAULT df_EmploymentDate AS GETDATE()
EXEC sp_bindefault df_EmploymentDate, 'hotel.tbl_employees.DateOfEmployment'

CREATE DEFAULT df_TransactionDate AS GETDATE()
EXEC sp_bindefault df_TransactionDate, 'hotel.tbl_transactions.TransactionDate'

CREATE DEFAULT df_MobilePhone AS '48000000000'
EXEC sp_bindefault df_MobilePhone, 'hotel.tbl_people_data.MobilelinePhoneNumber'
EXEC sp_bindefault df_MobilePhone, 'hotel.tbl_hotels.MobilelinePhoneNumber'

CREATE DEFAULT df_email AS 'default.mail@default.com'
EXEC sp_bindefault df_email, 'hotel.tbl_people_data.Email'
EXEC sp_bindefault df_MobilePhone, 'hotel.tbl_hotels.Email'

CREATE DEFAULT df_country AS 'Poland'
EXEC sp_bindefault df_email, 'hotel.tbl_people_data.Country'

CREATE DEFAULT df_PaymentDate AS GETDATE()
EXEC sp_bindefault df_PaymentDate, 'hotel.tbl_payments.PaymentDate'

CREATE DEFAULT df_LandlinePhoneNumber AS '(22) 123 45 67'
EXEC sp_bindefault df_LandlinePhoneNumber, 'hotel.tbl_hotels.LandlinePhoneNumber'


--regu³y

CREATE RULE rl_ZipCode as @ZipCode LIKE '[0-9][0-9]-[0-9][0-9][0-9]';
EXEC sp_bindrule rl_ZipCode, 'hotel.tbl_people_data.ZipCode'
EXEC sp_bindrule rl_ZipCode, 'hotel.tbl_hotels.ZipCode'

CREATE RULE rl_Email as @email LIKE '%[A-Z0-9][@][A-Z0-9]%[.][A-Z0-9]%' 
OR @email LIKE NULL;
EXEC sp_bindrule rl_Email, 'hotel.tbl_people_data.Email'
EXEC sp_bindrule rl_Email, 'hotel.tbl_hotels.Email'

CREATE RULE rl_DateOfBirth AS (@DateOfBirth < CAST(GETDATE() AS DATE));
EXEC sp_bindrule rl_DateOfBirth, 'hotel.tbl_people_data.DateOfBirth'

CREATE RULE rl_EmploymentDate AS (@EmploymentDate <= CAST(GETDATE() AS DATE));
EXEC sp_bindrule rl_EmploymentDate, 'hotel.tbl_employees.DateOfEmployment'

CREATE RULE rl_TransactionDate AS (@TransactionDate <= CAST(GETDATE() AS DATE));
EXEC sp_bindrule  rl_TransactionDate,'hotel.tbl_transactions.TransactionDate'

CREATE RULE rl_PaymentDate AS (@PaymentDate <= CAST(GETDATE() AS DATE));
EXEC sp_bindrule rl_PaymentDate, 'hotel.tbl_payments.PaymentDate'

CREATE RULE rl_MobilePhone as @MobilePhone LIKE '48[5-8][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
or @MobilePhone LIKE NULL;
EXEC sp_bindrule rl_MobilePhone, 'hotel.tbl_people_data.MobilelinePhoneNumber'
EXEC sp_bindrule rl_MobilePhone, 'hotel.tbl_hotels.MobilelinePhoneNumber'

CREATE RULE rl_IDNumber as @IDNumber LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]';
EXEC sp_bindrule rl_IDNumber, 'hotel.tbl_guests.IDNumber'

CREATE RULE rl_PassportNumber as @PassportNumber LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9]';
EXEC sp_bindrule rl_PassportNumber, 'hotel.tbl_guests.PassportNumber'

CREATE RULE rl_LandlinePhoneNumber as @LandlinePhoneNumber LIKE '([1-9][0-9]) [0-9][0-9][0-9] [0-9][0-9][0-9]' 
OR @LandlinePhoneNumber LIKE NULL;
EXEC sp_bindrule rl_LandlinePhoneNumber, 'hotel.tbl_hotels.LandlinePhoneNumber'

