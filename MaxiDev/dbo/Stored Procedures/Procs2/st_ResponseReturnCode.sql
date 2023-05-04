CREATE procedure [dbo].[st_ResponseReturnCode]                          

(                          

@IdGateway  int,                          

@Claimcode  nvarchar(max),                          

@ReturnCode nvarchar(max),                          

@ReturnCodeType int,                     

@XmlValue xml,                     

@IsCorrect bit output                          

)

/********************************************************************
<Author></Author>
<app> Corporate </app>
<Description>Se obtiene el codigo de respuesta</Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="03/08/2017" Author="snevarez">Se incluye a Banrural Pichincha(BANRP) como nuevo gateway</log>
<log Date="20/04/2018" Author="snevarez">Se incluye a Monty-Baloo(37) como nuevo gateway</log>
<log Date="10/12/2018" Author="adominguez">Se agrega "with(nolock)" a las consultas</log>
<log Date="18/06/2019" Author="jgomez">Se agregan los ReturnCodes en la validacion para Appriza M00057</log>]
<log Date="18/05/2022" Author="adominguez">Se agregan los ReturnCodes en la validacion para Corpounidas</log>
<log Date="2022-04-26" Author="jcsierra">Se agrega el gateway Pin4</log>
</ChangeLog>
*********************************************************************/

As

Set nocount on

Begin Try
Declare @SecondClaimcode nvarchar(max)

/********************************************************************
Cambiar este Id  correspondiente a Gateways de acuerdo al ambiente ejecutado, 
*********************************************************************/
Declare @IdGatewayTNWN int = 48 --Para STAGE sera el 47 para DEV 48 para PROD 46
Declare @IdGatewayCORPUNID int = 47 --Para STAGE sera el 48 para DEV 47 para PROD 47
Declare @IdGatewayCORPUNIDN int = 49 --Para STAGE sera el 49 para DEV 49 para PROD 48
/******************************************************************** 
*********************************************************************/

set @IsCorrect=1

DECLARE @IsReverse BIT = 0


DECLARE @IdTransfer		INT,
		@PrevIdStatus	INT

SELECT
	@IdTransfer = t.IdTransfer,
	@PrevIdStatus = t.IdStatus
FROM Transfer t WITH(NOLOCK)
WHERE t.ClaimCode = @Claimcode
-- AND t.IdGateway = @IdGateway

IF @IdGateway = 45
	SET @IdGateway = 32

IF @IdGateway = @IdGatewayTNWN  
	SET @IdGateway = 3

IF @IdGateway = @IdGatewayCORPUNIDN  
	SET @IdGateway = @IdGatewayCORPUNID

--Special case for Pagos Internacionales

If @IdGateway=14

Begin	

	Set @SecondClaimcode=@Claimcode

	Select @Claimcode=ClaimCode From Transfer WITH(NOLOCK) where IdTransfer in 

	(Select IdTransfer from ConsecutivoPagosInt WITH(NOLOCK) where IdConsecutivoPagosInt= CONVERT(int,@SecondClaimcode))    

End 




--Special case for MacroFin

If @IdGateway=15

Begin	

	Set @SecondClaimcode=@Claimcode

	Select @Claimcode=ClaimCode From Transfer WITH(NOLOCK) where IdTransfer in 

	(Select IdTransfer from MacroFinancieraSerial WITH(NOLOCK) where [IdMacroFinanciera]=CONVERT(int,@SecondClaimcode))    

End



--Special case for Servicentro

If @IdGateway=19

Begin	

	Set @SecondClaimcode=@Claimcode

	Select @Claimcode=ClaimCode From Transfer WITH(NOLOCK) where IdTransfer in 

	(Select IdTransfer from [ServiCentroSerial] WITH(NOLOCK) where [IdServiCentro]=CONVERT(int,@SecondClaimcode))    

End     







if ((@IdGateway=4 or @IdGateway=23) and @ReturnCode='C1200REVI' AND @ReturnCodeType=3) OR 

   ((@IdGateway=22 or @IdGateway=27) and @ReturnCode='004' AND @ReturnCodeType=3) or 

   (@IdGateway=20 and @ReturnCode='Revocado' AND @ReturnCodeType=3) or   

   (@IdGateway=3 and @ReturnCode='4050'AND @ReturnCodeType=3)  or

   (@IdGateway = 32 and @ReturnCode in ('SARL-NPD','SARJ-REJ','CNLO-CNL', 'CNLE-CNL', 'CNLN-CNL', 'PMTD-NPD', 'PMTO-PAD', 'PMRV-NPD','PMRJ-NPD')AND @ReturnCodeType=3) or

   (@IdGateway=34 and @ReturnCode='UPA'AND @ReturnCodeType=3) or

   (@IdGateway=35 and @ReturnCode='8'AND @ReturnCodeType=3) or--#1

   (@IdGateway=18 and @ReturnCode='1900' AND @ReturnCodeType=3) OR --#1

   (@IdGateway=@IdGatewayCORPUNID and @ReturnCode='PREV600' AND @ReturnCodeType=3) 

BEGIN

    SET @IsReverse=1

END



  

If Exists (Select top 1 1 from Transfer WITH(NOLOCK) where ClaimCode=@Claimcode and IdStatus in (30,31,22,27,28)) AND @IsReverse=0

        Begin  

         Declare @Today Datetime  

         Set @Today=GETDATE()  

  

         Insert into ResponseLogAlreadyFinalStatus        

         (  

		   Fecha,  

		   IdGateway,  

		   Claimcode,  

		   ReturnCode,  

		   ReturnCodeType,  

		   XMLResponse  

         )  

         Values  

         (  

		   @Today,  

		   @IdGateway,                            

		   @Claimcode,                            

		   @ReturnCode,                            

		   @ReturnCodeType,                       

		   @XmlValue  

         )  

   

         --Declare @Subject varchar(max)  

         --Set @Subject='Intento de modificar status final, Claimcode:'+@Claimcode  

         --exec   st_SendMail @Subject,'Intento de modificar status final'  

         Set @IsCorrect=1  

         Return  

  

        END 





/*Service Broker*/

If @IdGateway in (18,23)

begin

		 DECLARE

			@conversation uniqueidentifier,

			@msg xml



		set @msg =(

		SELECT 

			@IdGateway IdGateway,

			@Claimcode Claimcode,

			@ReturnCode ReturnCode,

			@ReturnCodeType ReturnCodeType,

			@XmlValue Response

		 FOR XML PATH ('Transfer'),ROOT ('GatewayDataType'))



		--- Start a conversation:

		BEGIN DIALOG @conversation

			FROM SERVICE [//Maxi/Transfer/GatewaySenderService]

			TO SERVICE N'//Maxi/Transfer/GatewayRecipService'

			ON CONTRACT [//Maxi/Transfer/GatewayContract]

			WITH ENCRYPTION=OFF;



		--- Send the message

		SEND ON CONVERSATION @conversation

			MESSAGE TYPE [//Maxi/Transfer/GatewayDataType]

			(@msg);





insert into dbo.SBSendGatewayMessageLog (ConversationID,MessageXML) values (@conversation,@msg)

end

/*End Service Broker*/



                    

If @IdGateway=10

Begin                    

 Exec  st_ResponseReturnCodeCibanco @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End                    

                  

If @IdGateway=3                    

Begin                    

 Exec  st_ResponseReturnCodeTNW @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End                  

              

If @IdGateway=8                    

Begin                    

 Exec  st_ResponseReturnCodeArias @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End                 



              

If @IdGateway=4                    

Begin                    

 Exec  st_ResponseReturnCodeBTS @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End   

            

          

If @IdGateway=9                    

Begin                    

 Exec  st_ResponseReturnCodeGirosLatinos @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End         

        

If @IdGateway=11                    

Begin                    

 Exec  st_ResponseReturnCodeCITI @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End                 



--13	BANRURAL	BANR

--36	BANRURAL Pichincha	BANRP

If @IdGateway=13 or @IdGateway=36

Begin                    

 --Exec  st_ResponseReturnCodeBanrural @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

 Exec  st_ResponseReturnCodeBanrural 13,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End    

  

If @IdGateway=14             

Begin                    

 Exec  st_ResponseReturnCodePagosInt @IdGateway,@SecondClaimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End  

  

If @IdGateway=16                    

Begin                    

 Exec  st_ResponseReturnCodeBancoIndustrial @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End 



If @IdGateway=15             

Begin                    

 Exec  st_ResponseReturnCodeMacroFinanciera @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End  



/*

If @IdGateway=18             

Begin                    

 Exec  st_ResponseReturnCodeChapina @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End 

*/ 





If @IdGateway=20

Begin                    

 Exec  st_ResponseReturnCodeIntermex @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End 





If (@IdGateway=22 or @IdGateway=27)

Begin                    

    eXEC st_ResponseReturnCodeUniteller 22,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End



If @IdGateway=19

Begin                    

 Exec  st_ResponseReturnCodeServiCentro @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End 





If @IdGateway=24

Begin                    

 Exec  st_ResponseReturnCodeGirosMex @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End 







If @IdGateway=25 or @IdGateway=26              

Begin                    

 --Exec  st_ResponseReturnCodeInpamex @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

 Exec  st_ResponseReturnCodeInpamexV2 @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                     

End 



If @IdGateway=28             

Begin                    

	 Exec  [dbo].[st_ResponseReturnCodePontual] @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End



If @IdGateway=30                    

Begin                    

 Exec  st_ResponseReturnCodeBancoUnion @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End 





If @IdGateway=31                    

Begin                    

 Exec  st_ResponseReturnCodeTransferToMobile @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

End 



If @IdGateway = 32            

    Begin                    

	 Exec  [dbo].[st_ResponseReturnCodeAppriza] @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

	End



If @IdGateway=35             

    Begin                    

	 Exec  [dbo].[st_ResponseReturnTTOApi] @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

	End



If @IdGateway=34

    Begin                    

	 Exec  [dbo].[st_ResponseReturnCodeGp] @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    

	End


IF @IdGateway = 37
BEGIN
	EXEC st_ResponseReturnCodeFicosa @IdGateway, @Claimcode, @ReturnCode, @ReturnCodeType, @XmlValue, @IsCorrect OUTPUT
END

IF @IdGateway = 38
BEGIN

	EXEC st_ResponseReturnCodeBalsas @IdGateway, @Claimcode, @ReturnCode, @ReturnCodeType, @XmlValue, @IsCorrect OUTPUT
END

IF @IdGateway = 39
	EXEC st_ResponseReturnCode24Xoro @IdGateway, @Claimcode, @ReturnCode, @ReturnCodeType, @XmlValue, @IsCorrect OUTPUT
        
IF @IdGateway = 44
	EXEC st_ResponseReturnCodeMoneyGram @IdGateway, @Claimcode, @ReturnCode, @ReturnCodeType, @XmlValue, @IsCorrect OUTPUT

IF @IdGateway=@IdGatewayCORPUNID
	EXEC st_ResponseReturnCodeCorporacionesUnidas @IdGateway, @Claimcode, @ReturnCode, @ReturnCodeType, @XmlValue, @IsCorrect OUTPUT

IF @IdGateway=51
	EXEC st_ResponseReturnCodeBankaya @IdGateway, @Claimcode, @ReturnCode, @ReturnCodeType, @XmlValue, @IsCorrect OUTPUT

IF @IdGateway IN (53 /*46*/, 50)
	EXEC st_ResponseReturnCodePin4 @IdGateway, @Claimcode, @ReturnCode, @ReturnCodeType, @XmlValue, @IsCorrect OUTPUT

DECLARE @NewIdStatus	INT

SELECT
	@NewIdStatus = t.IdStatus
FROM Transfer t WITH(NOLOCK)
WHERE t.IdTransfer = @IdTransfer

DECLARE @LogDescription VARCHAR(MAX)

IF (@IsCorrect = 1 AND @PrevIdStatus <> @NewIdStatus)
BEGIN
	IF EXISTS (SELECT TOP 1 * FROM TransferModify WITH(NOLOCK) WHERE OldIdTransfer = @IdTransfer and IsCancel = 0) AND @NewIdStatus NOT IN (22, 25, 26, 35)
		EXEC st_TransferModifyResponseGateway @IdTransfer, 0
	ELSE IF @NewIdStatus = 22 AND EXISTS (SELECT TOP 1 * FROM TransferModify WITH(NOLOCK) WHERE OldIdTransfer = @IdTransfer)
		EXEC st_TransferModifyResponseGateway @IdTransfer, 1
END

End try
begin catch       
	Declare @ErrorMessages nvarchar(max)                                                                                             
	Select @ErrorMessages=ERROR_MESSAGE()                                                  
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('dbo.st_ResponseReturnCode',Getdate(),@ErrorMessages)                                                                                            
end catch


