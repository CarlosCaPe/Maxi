CREATE Procedure [Corp].[st_AgentsSubaccount]
(
  @IdsAgent Varchar(Max)

)   
as
	
declare @cadena VARCHAR(MAX)
declare @separator VARCHAR(MAX)


	 set @separator = ','
	 set @cadena = @IdsAgent

declare  @tabla table
(
    value VARCHAR(MAX)
)


   DECLARE @individual varchar(max) = null

   WHILE LEN(@cadena) > 0
   BEGIN
       IF PATINDEX('%' + @separator + '%',@cadena) > 0
       BEGIN
          SET @individual = SUBSTRING(@cadena, 0, PATINDEX('%' + @separator + '%',@cadena))
          INSERT INTO @tabla values(@individual)

         SET @cadena = SUBSTRING(@cadena, LEN(@individual + @separator) + 1,       LEN(@cadena))
       END
       ELSE
       BEGIN
          SET @individual = @cadena
          SET @cadena = NULL
          INSERT INTO @tabla values(@individual)
       END
  
  END 


  Select IdAgent, SubAccount from Agent with(nolock) where idagent in (select * from  @tabla)
