CREATE Procedure [dbo].[st_AgentsSubaccount]
(
  @IdsAgent Varchar(Max)

)   
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
	
declare @cadena VARCHAR(MAX)
declare @separator VARCHAR(MAX)


	 set @separator = ','
	 set @cadena = @IdsAgent

declare  @tabla table
(
    value VARCHAR(MAX)
);


   DECLARE @individual varchar(max) = null

   WHILE LEN(@cadena) > 0
   BEGIN
       IF PATINDEX('%' + @separator + '%',@cadena) > 0
       BEGIN
          SET @individual = SUBSTRING(@cadena, 0, PATINDEX('%' + @separator + '%',@cadena))
          INSERT INTO @tabla values(@individual);

         SET @cadena = SUBSTRING(@cadena, LEN(@individual + @separator) + 1,       LEN(@cadena))
       END
       ELSE
       BEGIN
          SET @individual = @cadena
          SET @cadena = NULL
          INSERT INTO @tabla values(@individual);
       END
  
  END 


  SELECT IdAgent, SubAccount FROM Agent with(nolock) WHERE idagent in (SELECT * FROM  @tabla)
