CREATE procedure [Ofac].[BackupClean]
as
truncate table ofac_sdn2
truncate table ofac_alt2

insert into ofac_sdn2
select ent_num, SDN_name, SDN_type, program, title, call_sign, vess_type, tonnage, GRT, vess_flag, vess_owner, remarks, SDN_PrincipalName, SDN_FirstLastName from ofac_sdn

insert into ofac_alt2
select ent_num, alt_num, alt_type, alt_name, alt_remarks, ALT_PrincipalName, ALT_FirstLastName from ofac_alt

truncate table ofac_sdn
truncate table ofac_alt

