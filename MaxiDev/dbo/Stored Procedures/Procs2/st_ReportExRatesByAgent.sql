CREATE PROCEDURE [dbo].[st_ReportExRatesByAgent]            
 (            
 @IdAgent INT            
 )            
AS            
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
          
            
CREATE TABLE #Result             
 (            
 PayerName1 Varchar(max),            
 PayerImage1 Varchar(max),            
 PayerExrate1 Money,            
 PayerImage2 Varchar(max),            
 PayerExrate2  Money,            
 PayerImage3 Varchar(max),            
 PayerExrate3  Money,            
 PayerImage4 Varchar(max),            
 PayerExrate4  Money,            
 PayerImage5 Varchar(max),            
 PayerExrate5  Money,            
 PayerImage6 Varchar(max),            
 PayerExrate6  Money,            
 PayerImage7 Varchar(max),            
 PayerExrate7  Money,   
   
 CountryImage1 Varchar(max),  
 CountryExrate1  Money,  
 CountryName1 Varchar(max),   
 CountryImage2 Varchar(max),  
 CountryExrate2  Money,  
 CountryName2 Varchar(max),   
 CountryImage3 Varchar(max),  
 CountryExrate3  Money,  
 CountryName3 Varchar(max),   
 CountryImage4 Varchar(max),  
 CountryExrate4  Money,  
 CountryName4 Varchar(max),  
   
 CountrySendDollarImage1 Varchar(max),  
 CountrySendDollarName1 Varchar(max),  
 CountrySendDollarImage2 Varchar(max),  
 CountrySendDollarName2 Varchar(max),  
 CountrySendDollarImage3 Varchar(max),  
 CountrySendDollarName3 Varchar(max),  
 CountrySendDollarImage4 Varchar(max),  
 CountrySendDollarName4 Varchar(max),  
 CountrySendDollarImage5 Varchar(max),  
 CountrySendDollarName5 Varchar(max),  
 CountrySendDollarImage6 Varchar(max),  
 CountrySendDollarName6 Varchar(max),  
 CountrySendDollarImage7 Varchar(max),  
 CountrySendDollarName7 Varchar(max),  
 CountrySendDollarImage8 Varchar(max),  
 CountrySendDollarName8 Varchar(max)  
)  
             
            
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
Insert Into  #RESULT (PayerName1,PayerImage1,PayerExrate1)VALUES (@PayerName,@PayerLogo,@ExRate);            
  
Set @ExRate=0;  
Set @PayerLogo='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=2;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Update #RESULT Set PayerImage2=@PayerLogo,PayerExrate2=@ExRate;  
            
Set @ExRate=0;  
Set @PayerLogo='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=3;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Update #RESULT Set PayerImage3=@PayerLogo,PayerExrate3=@ExRate;  
  
Set @ExRate=0;  
Set @PayerLogo='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=4;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Update #RESULT Set PayerImage4=@PayerLogo,PayerExrate4=@ExRate;  
  
Set @ExRate=0;  
Set @PayerLogo='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=5;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT;  
Update #RESULT Set PayerImage5=@PayerLogo,PayerExrate5=@ExRate;  
  
Set @ExRate=0;  
Set @PayerLogo='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=6;            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT ; 
Update #RESULT Set PayerImage6=@PayerLogo,PayerExrate6=@ExRate;  
  
Set @ExRate=0  
Set @PayerLogo=''  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=7            
EXEC st_FindBestExrateByAgentInMX @IdAgent,@ID,@ExRate OUTPUT,@PayerLogo OUTPUT,@PayerName OUTPUT  
Update #RESULT Set PayerImage7=@PayerLogo,PayerExrate7=@ExRate  
  
Set @ExRate=0;  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=8;            
Exec st_FindBestExrateByAgentByCountry @IdAgent,@ID, @ExRate Output,@CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountryImage1=@CountryFlag,CountryExrate1=@ExRate,CountryName1=@CountryName;  
  
Set @ExRate=0;  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=9;            
Exec st_FindBestExrateByAgentByCountry @IdAgent,@ID, @ExRate Output,@CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountryImage2=@CountryFlag,CountryExrate2=@ExRate,CountryName2=@CountryName;  
  
Set @ExRate=0;  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=10;            
Exec st_FindBestExrateByAgentByCountry @IdAgent,@ID, @ExRate Output,@CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountryImage3=@CountryFlag,CountryExrate3=@ExRate,CountryName3=@CountryName;  
  
Set @ExRate=0;  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=11;            
Exec st_FindBestExrateByAgentByCountry @IdAgent,@ID, @ExRate Output,@CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountryImage4=@CountryFlag,CountryExrate4=@ExRate,CountryName4=@CountryName;  
  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=12;            
Exec st_FindCoutryByAgent @IdAgent,@ID, @CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountrySendDollarImage1=@CountryFlag,CountrySendDollarName1=@CountryName;  
  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=13;           
Exec st_FindCoutryByAgent @IdAgent,@ID, @CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountrySendDollarImage2=@CountryFlag,CountrySendDollarName2=@CountryName;  
  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=14;            
Exec st_FindCoutryByAgent @IdAgent,@ID, @CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountrySendDollarImage3=@CountryFlag,CountrySendDollarName3=@CountryName;  
  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=15;            
Exec st_FindCoutryByAgent @IdAgent,@ID, @CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountrySendDollarImage4=@CountryFlag,CountrySendDollarName4=@CountryName;  
  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=16;            
Exec st_FindCoutryByAgent @IdAgent,@ID, @CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountrySendDollarImage5=@CountryFlag,CountrySendDollarName5=@CountryName;  
  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig WHERE ID_Report=17;            
Exec st_FindCoutryByAgent @IdAgent,@ID, @CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountrySendDollarImage6=@CountryFlag,CountrySendDollarName6=@CountryName;  
  
Set @CountryFlag='';  
Set @CountryName='';  
SELECT @ID=ValueIn FROM ReportExRatesConfig WHERE ID_Report=18;            
Exec st_FindCoutryByAgent @IdAgent,@ID, @CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountrySendDollarImage7=@CountryFlag,CountrySendDollarName7=@CountryName;  
  
Set @CountryFlag='';  
Set @CountryName='' ; 
SELECT @ID=ValueIn FROM ReportExRatesConfig with(nolock) WHERE ID_Report=19;            
Exec st_FindCoutryByAgent @IdAgent,@ID, @CountryFlag Output,@CountryName Output;  
Update #RESULT Set CountrySendDollarImage8=@CountryFlag,CountrySendDollarName8=@CountryName;  
  
  
select   
PayerName1 ,            
 PayerImage1 ,            
 PayerExrate1 ,            
 PayerImage2 ,            
 PayerExrate2  ,            
 PayerImage3 ,            
 PayerExrate3  ,            
 PayerImage4 ,            
 PayerExrate4  ,            
 PayerImage5 ,            
 PayerExrate5  ,            
 PayerImage6 ,            
 PayerExrate6  ,            
 PayerImage7 ,            
 PayerExrate7  ,   
   
 CountryImage1 ,  
 CountryExrate1  ,  
 CountryName1 ,   
 CountryImage2 ,  
 CountryExrate2  ,  
 CountryName2 ,   
 CountryImage3 ,  
 CountryExrate3  ,  
 CountryName3 ,   
 CountryImage4 ,  
 CountryExrate4  ,  
 CountryName4 ,  
   
 CountrySendDollarImage1 ,  
 CountrySendDollarName1 ,  
 CountrySendDollarImage2 ,  
 CountrySendDollarName2 ,  
 CountrySendDollarImage3 ,  
 CountrySendDollarName3 ,  
 CountrySendDollarImage4 ,  
 CountrySendDollarName4 ,  
 CountrySendDollarImage5 ,  
 CountrySendDollarName5 ,  
 CountrySendDollarImage6 ,  
 CountrySendDollarName6 ,  
 CountrySendDollarImage7 ,  
 CountrySendDollarName7 ,  
 CountrySendDollarImage8 ,  
 CountrySendDollarName8   
  
from #Result;
