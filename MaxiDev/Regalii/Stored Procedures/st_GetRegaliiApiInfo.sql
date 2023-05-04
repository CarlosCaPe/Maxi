create procedure [Regalii].[st_GetRegaliiApiInfo]
as

declare @APIApiKey varchar(100)=(select Value from GlobalAttributes where Name='Regalli_APIApiKey')
declare @APISecretKey varchar(100)=(select Value from GlobalAttributes where Name='Regalli_APISecretKey')
declare @APIURL varchar(100)=(select Value from GlobalAttributes where Name='Regalli_APIURL')


select
@APIApiKey 'APIApiKey',
@APISecretKey 'APISecretKey',
@APIURL 'APIURL'

