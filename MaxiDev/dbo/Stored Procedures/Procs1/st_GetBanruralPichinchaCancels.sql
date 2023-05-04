CREATE procedure [dbo].[st_GetBanruralPichinchaCancels]
/********************************************************************
<Author></Author>
<app> Corporate </app>
<Description>Obtiene las solicitudes de cancelacion de remesas de Banrural Pichincha para ser enviadas al pagador</Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="03/08/2017" Author="snevarez">Obtiene las solicitudes de cancelacion de remesas de Banrural Pichincha para ser enviadas al pagador</log>
</ChangeLog>
*********************************************************************/    
as        
Set Nocount on

--13	BANRURAL	BANR
--36	BANRURAL Pichincha	BANRP
    Select  
	   ClaimCode
	   ,getdate() as CancellationDate  
    From Transfer 
	   Where IdGateway = 13 and IdStatus = 25
		  and IdPayer = 4023; /*Banco Pichincha*/

