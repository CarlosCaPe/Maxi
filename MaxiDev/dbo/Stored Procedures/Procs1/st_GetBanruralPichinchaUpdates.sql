CREATE  procedure [dbo].[st_GetBanruralPichinchaUpdates]            
/********************************************************************
<Author></Author>
<app> Corporate </app>
<Description>Actualizacion de remesas de Banrural Pichincha</Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="03/08/2017" Author="snevarez">Actualizacion de remesas de Banrural Pichincha(BANRP)</log>
</ChangeLog>
*********************************************************************/
as            
Set Nocount on           

--13	BANRURAL	BANR
--36	BANRURAL Pichincha	BANRP

Select  
    ClaimCode  
From Transfer
    Where IdGateway = 13
	   and IdStatus in (25,23,26,35,40,29)    
	   and IdPayer = 4023; /*Banco Pichincha*/

