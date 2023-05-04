CREATE PROCEDURE [dbo].[st_NewReportExRatesByAgent]            
 (            
     @IdAgent INT,
     @IdReportPart int            
 )            
AS            
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add ; and with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;



declare @ImgDefault nvarchar(max) = 'NotSelected.jpg'

            
CREATE TABLE #Result             
 (    
 Id int,
 Name Varchar(max),            
 [Image] Varchar(max),            
 Exrate Money,
 IsCountry bit
) ; 

CREATE TABLE #ResultOut            
 (    
 IdRow int Identity (1,1),
 Id int,
 Name Varchar(max),            
 [Image] Varchar(max),            
 Exrate Money,
 IsCountry bit
) ;
  
                
----------Var-----------------------            
DECLARE @ID INT            
DECLARE @ExRate money,  
  @PayerLogo nvarchar(max),  
  @PayerName nvarchar(max),  
  @CountryFlag nvarchar(max),  
  @CountryName nvarchar(max)           
            
------------------Insert into Temp-----------------------------------------      
Set @ExRate=0;  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=1;
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (1,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0);            
  
Set @ExRate=0;  
Set @PayerLogo='';  set @Payername='';
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=2;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (2,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0);  
            
Set @ExRate=0;  
Set @PayerLogo='';  set @Payername='';
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=3;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (3,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0);  
  
Set @ExRate=0;  
Set @PayerLogo='';  set @Payername='';
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=4;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (4,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0);   
  
Set @ExRate=0;  
Set @PayerLogo='';  set @Payername='';
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=5;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (5,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0);  
  
Set @ExRate=0;  
Set @PayerLogo='';  set @Payername='';
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=6;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (6,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0);  
  
--nuevos pagadores
declare @idcountrycurrency1 int;
declare @idcountrycurrency2 int;

SELECT @idcountrycurrency1=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=8;
SELECT @idcountrycurrency2=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=9; 

Set @ExRate=0;  
Set @PayerLogo='';  set @Payername='';
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=20;           
EXEC st_FindBestExrateByAgent @IdAgent,@ID,@idcountrycurrency1,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (20,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0); 

Set @ExRate=0;  
Set @PayerLogo='';  set @Payername='';
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=21;
EXEC st_FindBestExrateByAgent @IdAgent,@ID,@idcountrycurrency1,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (21,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0); 

Set @ExRate=0;  
Set @PayerLogo='';  set @Payername='';
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=23;
EXEC st_FindBestExrateByAgent @IdAgent,@ID,@idcountrycurrency2,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (23,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0); 

Set @ExRate=0;  
Set @PayerLogo='';  set @Payername='';
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=24;
EXEC st_FindBestExrateByAgent @IdAgent,@ID,@idcountrycurrency2,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry)VALUES (24,@PayerName,case when isnull(@PayerLogo,'')='' then @ImgDefault else @PayerLogo end,@ExRate,0); 

--paises
  
Set @ExRate=0;  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=8;            
Exec st_FindBestExrateByAgentByCountry @IdAgent,@ID, @ExRate Output,@CountryFlag Output,@CountryName Output;  
Insert Into  #RESULT (Id,Name,[Image],Exrate,IsCountry) values(8,@CountryName,@CountryFlag,@ExRate,1);

  
Set @ExRate=0;  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=9;            
Exec st_FindBestExrateByAgentByCountry @IdAgent,@ID, @ExRate Output,@CountryFlag Output,@CountryName Output;  
Insert Into  #RESULT  (Id,Name,[Image],Exrate,IsCountry) values(9,@CountryName,@CountryFlag,@ExRate,1);
  
Set @ExRate=0;  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=10;            
Exec st_FindBestExrateByAgentByCountry @IdAgent,@ID, @ExRate Output,@CountryFlag Output,@CountryName Output;  
Insert Into  #RESULT  (Id,Name,[Image],Exrate,IsCountry) values(10,@CountryName,@CountryFlag,@ExRate,1);
  
Set @ExRate=0;  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=11;            
Exec st_FindBestExrateByAgentByCountry @IdAgent,@ID, @ExRate Output,@CountryFlag Output,@CountryName Output;  
Insert Into  #RESULT  (Id,Name,[Image],Exrate,IsCountry) values(11,@CountryName,@CountryFlag,@ExRate,1);

if @IdReportPart= 1
    insert into #ResultOut
    select   * from #Result where id in (1);  
  
if @IdReportPart= 2
insert into #ResultOut
select   * from #Result where id in (2,3,4,5,6,7) and exrate>0 order by id;

if @IdReportPart= 3
insert into #ResultOut
select   * from #Result where id in (8,20,21,22) and exrate>0 order by iscountry desc,exrate DESC ,name;

if @IdReportPart= 4
insert into #ResultOut
select   * from #Result where id in (9,23,24,25) and exrate>0 order by iscountry desc,exrate,name;

if @IdReportPart= 5
insert into #ResultOut
select   * from #Result where id in (10,11) and exrate>0 order by id;


update #ResultOut set name='Argentina' where name='ARGENTINA';
update #ResultOut set name='Bolivia' where name='BOLIVIA';
update #ResultOut set name='Brasil' where name='BRASIL';
update #ResultOut set name='Brazil' where name='BRAZIL';
update #ResultOut set name='Colombia' where name='COLOMBIA';
update #ResultOut set name='Ecuador' where name='ECUADOR';
update #ResultOut set name='El Salvador' where name='EL SALVADOR';
update #ResultOut set name='Guatemala' where name='GUATEMALA';
update #ResultOut set name='Honduras' where name='HONDURAS';
update #ResultOut set name='Mexico' where name='MEXICO';
update #ResultOut set name='Nicaragua' where name='NICARAGUA';
update #ResultOut set name='Panama' where name='PANAMA';
update #ResultOut set name='Paraguay' where name='PARAGUAY';
update #ResultOut set name='Peru' where name='PERU';
update #ResultOut set name='Dominicana' where name='DOMINICAN REPUBLIC';
update #ResultOut set name='Uruguay' where name='URUGUAY';
update #ResultOut set name='Usa' where name='USA';
update #ResultOut set name='Costa Rica' where name='COSTA RICA';
update #ResultOut set name='Marruecos' where name='MARRUECOS';
update #ResultOut set name='Filipinas' where name='FILIPINAS';
update #ResultOut set name='Senegal' where name='SENEGAL';
update #ResultOut set name='Vietnam' where name='VIETNAM';
update #ResultOut set name='China' where name='CHINA';
update #ResultOut set name='India' where name='INDIA';
update #ResultOut set name='Pakistan' where name='PAKISTAN';

select * from #ResultOut order by IdRow;

