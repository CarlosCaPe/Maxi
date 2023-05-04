


CREATE PROCEDURE  [dbo].[CreateBancomerReceiptFolio]               
    @IdCountryCurrency INT,                           
    @IdPayer INT,                                   
    @BancomerClaimCode   nvarchar(30) OUTPUT,                            
    @FolioResult  int  OUTPUT                                
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="15/07/2014" Author="">Prefijo 1665 activado</log>
<log Date="04/02/2015" Author="">Prefijo 1691 activado</log>
<log Date="25/07/2015" Author="">Prefijo 1712 activado</log>
<log Date="04/08/2017" Author="">Prefijo 1808 activado</log>
<log Date="26/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
<log Date="25/01/2018" Author="jmolina">Se agrego validación en envío de mail</log>
<log Date="29/01/2018" Author="jmolina">Prefijo 1834 activado</log>
<log Date="08/11/2018" Author="jdarellano">Prefijo 1846 activado</log>
<log Date="09/06/2019" Author="jhornedo">Prefijo 1883 activado</log>
<log Date="06/12/2019" Author="jdarellano">Prefijo 1902 activado</log>
</ChangeLog>
********************************************************************/
 BEGIN                            
 ----------------------------------------------------------------------------------------------------                            
 DECLARE  @ClaveN    BIGINT,                            
   @Clave    VARCHAR(10),                            
   @Num   VARCHAR(2),                            
   @NumeroCD    VARCHAR(11),                            
   @Numero   INTEGER,                             
   @Numero1  INTEGER,                             
   @Numero2  INTEGER,                             
   @NumTot  INTEGER,                            
   @N1   INTEGER,                            
   @N2   INTEGER,                            
   @N3   INTEGER,                            
   @N4   INTEGER,                            
   @N5   INTEGER,                            
   @N6   INTEGER,                            
   @N7   INTEGER                            
 ----------------------------------------------------------------------------------------------------                            
 SET @numeroCD = ''                            
 SET @NumTot = 0                            
 ----------------------------------------------------------------------------------------------------                            
                       
              
 IF @IdPayer=433 and  (@IdCountryCurrency=9 or @IdCountryCurrency=10)             
 Begin              
              
  declare @consecutive int              
  exec GetNextHSBCFolioNumber @consecutive out              
              
   IF  @IdCountryCurrency=9                             
   Begin              
    SET @ClaveN = 50020000000+@consecutive                                   
   End              
   ELSE                
   Begin              
       IF  @IdCountryCurrency=10                           
     Begin              
      SET @ClaveN = 40820000000+@consecutive                
      if @consecutive>=9985000              
       exec st_SendMail 'ClaimCode HSBC','Estan por acabarse los numero de bancomer '               
     End              
   End              
              
  Set @BancomerClaimCode=convert(varchar,@ClaveN)  --Para HSBC el claim code es de 4 digios prefijo y 7 digitos de consecitivo              
               
 End              
 ELSE IF (@IdPayer=499 or @IdPayer=502) and @IdCountryCurrency=10  -- Caja Popular y Farmcias ISSEG
 Begin 
	Declare @currentNumber int  
	Declare @prefijo bigint
	Declare @warningConfirmation int
	
	select @prefijo= prefijo, @currentNumber=Folio, @warningConfirmation= WarningConfirmationNumber  from BtsFolios where Code='CP'
	set @currentNumber= @currentNumber+1
	Update BtsFolios set Folio= @currentNumber where Code='CP'
	set @ClaveN=@prefijo + @currentNumber
	
	if @currentNumber>=@warningConfirmation             
     exec st_SendMail 'ClaimCode Bancomer Caja Popular, Farmacias ISSEG ','Estan por acabarse los numero de bancomer Caja Popular, Farmacias ISSEG'    
	Set @BancomerClaimCode=convert(varchar,@ClaveN) 
 End
 Else               
 Begin              
              
    UPDATE  PAYER                             
     SET  folio = folio+1,                            
      @FolioResult=folio+1                            
     WHERE PayerName = 'BANCOMER'

	 DECLARE @SendMessage bit
	 EXEC [dbo].[st_ClaimCodeNotification] @FolioResult, @IdPayer, @SendMessage out
              
    --  1449000000 production                             
    --SET @ClaveN = 1367000000+@v_resultado_folio  --Anterio prefijo      ,,  
    -- Prefijo 1619 activado 8 de Noviembre   
   --SET @ClaveN = 1808000000+@FolioResult        
   --SET @ClaveN = 1834000000+@FolioResult
   --SET @ClaveN = 1846000000+@FolioResult
   --SET @ClaveN = 1883000000+@FolioResult
   --SET @ClaveN = 1902000000+@FolioResult
   SET @ClaveN = 1106000000+@FolioResult
   Set @BancomerClaimCode=dbo.[fn_DigitoVerificadorBTS](convert(varchar,@ClaveN))--Para BTS elclaimCode es 4 digitos prefijo, 6 consecutivo, 1 verificador              
   --if @FolioResult>=950000              
   IF @SendMessage = 1
   BEGIN
		declare @subject varchar(500)='Estan por acabarse los numero de bancomer ('+ CONVERT(varchar,@FolioResult)+').'
		--exec st_SendMail 'ClaimCode Bancomer','Estan por acabarse los numero de bancomer '
		exec st_SendMail 'ClaimCode Bancomer (BTS)',@subject
   END
 End              
               
 END 

