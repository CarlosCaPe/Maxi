create procedure ofac.RestoreInfo
as
truncate table ofac_sdn
truncate table ofac_alt

insert into ofac_sdn
select * from ofac_sdn2

insert into ofac_alt
select * from ofac_alt2